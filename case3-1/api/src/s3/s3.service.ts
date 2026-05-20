import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { getSignedUrl as getCFSignedUrl } from '@aws-sdk/cloudfront-signer';

@Injectable()
export class S3Service {
  private readonly s3: S3Client;
  private readonly bucket: string;
  private readonly cloudfrontDomain: string;
  private readonly cloudfrontKeyPairId: string;
  private readonly cloudfrontPrivateKey: string;

  constructor(private readonly config: ConfigService) {
    this.s3 = new S3Client({ region: config.get('S3_BUCKET_REGION', 'ap-northeast-1') });
    this.bucket = config.get('S3_BUCKET_NAME');
    this.cloudfrontDomain = config.get('CLOUDFRONT_DOMAIN');
    this.cloudfrontKeyPairId = config.get('CLOUDFRONT_KEY_PAIR_ID', '');
    this.cloudfrontPrivateKey = config.get('CLOUDFRONT_PRIVATE_KEY', '').replace(/\\n/g, '\n');
  }

  // フロントエンドが S3 に直接 PUT するための presigned URL を発行
  async getPresignedUploadUrl(key: string, expiresIn = 300): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
    });
    return getSignedUrl(this.s3, command, { expiresIn });
  }

  // CloudFront Signed URL 発行（画像取得）
  async getSignedUrl(key: string, expiresIn = 3600): Promise<string> {
    if (!this.cloudfrontKeyPairId || !this.cloudfrontPrivateKey) {
      // 開発環境: S3 presigned URL にフォールバック
      const command = new GetObjectCommand({ Bucket: this.bucket, Key: key });
      return getSignedUrl(this.s3, command, { expiresIn });
    }

    return getCFSignedUrl({
      url: `https://${this.cloudfrontDomain}/${key}`,
      keyPairId: this.cloudfrontKeyPairId,
      privateKey: this.cloudfrontPrivateKey,
      dateLessThan: new Date(Date.now() + expiresIn * 1000).toISOString(),
    });
  }

  async deleteObject(key: string): Promise<void> {
    await this.s3.send(new DeleteObjectCommand({ Bucket: this.bucket, Key: key }));
  }
}
