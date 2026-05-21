import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import { ExportJob } from './export-job.entity';
import { ConfigService } from '@nestjs/config';
import { S3Service } from '../s3/s3.service';

@Injectable()
export class ExportsService {
  private readonly sqs: SQSClient;
  private readonly queueUrl: string;

  constructor(
    @InjectRepository(ExportJob)
    private readonly repo: Repository<ExportJob>,
    private readonly config: ConfigService,
    private readonly s3: S3Service,
  ) {
    this.sqs = new SQSClient({ region: config.get('AWS_REGION', 'ap-northeast-1') });
    this.queueUrl = config.get('SQS_QUEUE_URL', '');
  }

  async createJob(): Promise<ExportJob> {
    const job = await this.repo.save(this.repo.create({ status: 'pending' }));

    await this.sqs.send(new SendMessageCommand({
      QueueUrl: this.queueUrl,
      MessageBody: JSON.stringify({ jobId: job.id }),
    }));

    return job;
  }

  async getJob(id: number): Promise<ExportJob & { downloadUrl?: string }> {
    const job = await this.repo.findOneOrFail({ where: { id } });

    if (job.status === 'complete' && job.s3Key) {
      const downloadUrl = await this.s3.getSignedUrl(job.s3Key, 3600);
      return { ...job, downloadUrl };
    }

    return job;
  }
}
