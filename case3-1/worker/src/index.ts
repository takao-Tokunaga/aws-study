import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from '@aws-sdk/client-sqs';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { Pool } from 'pg';
import { stringify } from 'csv-stringify/sync';

const region = process.env.AWS_REGION || 'ap-northeast-1';
const queueUrl = process.env.SQS_QUEUE_URL!;
const bucketName = process.env.S3_BUCKET_NAME!;

const sqs = new SQSClient({ region });
const s3 = new S3Client({ region });

const db = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false },
});

async function processJob(jobId: number): Promise<void> {
  console.log(`Processing job ${jobId}`);

  await db.query(`UPDATE export_jobs SET status='processing', updated_at=NOW() WHERE id=$1`, [jobId]);

  const { rows } = await db.query(
    `SELECT id, title, description, status, picture_s3_key, created_at FROM tasks ORDER BY created_at DESC`
  );

  const csv = stringify(rows, {
    header: true,
    columns: [
      { key: 'id', header: 'ID' },
      { key: 'title', header: 'タイトル' },
      { key: 'description', header: '説明' },
      { key: 'status', header: 'ステータス' },
      { key: 'picture_s3_key', header: '画像キー' },
      { key: 'created_at', header: '作成日時' },
    ],
  });

  const s3Key = `exports/${jobId}-tasks.csv`;
  await s3.send(new PutObjectCommand({
    Bucket: bucketName,
    Key: s3Key,
    Body: Buffer.from('﻿' + csv, 'utf8'),
    ContentType: 'text/csv; charset=utf-8',
  }));

  await db.query(
    `UPDATE export_jobs SET status='complete', s3_key=$1, updated_at=NOW() WHERE id=$2`,
    [s3Key, jobId]
  );

  console.log(`Job ${jobId} complete: ${s3Key}`);
}

async function poll(): Promise<void> {
  console.log('Worker started. Polling SQS...');

  while (true) {
    try {
      const result = await sqs.send(new ReceiveMessageCommand({
        QueueUrl: queueUrl,
        MaxNumberOfMessages: 1,
        WaitTimeSeconds: 20,
      }));

      const messages = result.Messages || [];
      for (const msg of messages) {
        const body = JSON.parse(msg.Body!);
        const jobId: number = body.jobId;

        try {
          await processJob(jobId);
        } catch (err) {
          console.error(`Job ${jobId} failed:`, err);
          await db.query(`UPDATE export_jobs SET status='failed', updated_at=NOW() WHERE id=$1`, [jobId]);
        }

        await sqs.send(new DeleteMessageCommand({
          QueueUrl: queueUrl,
          ReceiptHandle: msg.ReceiptHandle!,
        }));
      }
    } catch (err) {
      console.error('Poll error:', err);
      await new Promise(r => setTimeout(r, 5000));
    }
  }
}

poll().catch(err => {
  console.error('Fatal:', err);
  process.exit(1);
});
