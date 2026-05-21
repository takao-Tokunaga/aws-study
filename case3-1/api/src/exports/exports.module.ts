import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExportJob } from './export-job.entity';
import { ExportsService } from './exports.service';
import { ExportsController } from './exports.controller';
import { S3Module } from '../s3/s3.module';

@Module({
  imports: [TypeOrmModule.forFeature([ExportJob]), S3Module],
  controllers: [ExportsController],
  providers: [ExportsService],
})
export class ExportsModule {}
