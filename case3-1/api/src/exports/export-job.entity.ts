import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export type ExportStatus = 'pending' | 'processing' | 'complete' | 'failed';

@Entity('export_jobs')
export class ExportJob {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 20, default: 'pending' })
  status: ExportStatus;

  @Column({ name: 's3_key', type: 'varchar', length: 500, nullable: true })
  s3Key: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
