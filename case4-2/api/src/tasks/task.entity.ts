import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

export enum TaskStatus {
  PENDING     = 'pending',
  IN_PROGRESS = 'in_progress',
  DONE        = 'done',
}

@Entity('tasks')
export class Task {
  @ApiProperty({ example: 1 })
  @PrimaryGeneratedColumn()
  id: number;

  @ApiProperty({ example: 'ミーティング資料を準備する' })
  @Column({ length: 255 })
  title: string;

  @ApiProperty({ required: false })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({ enum: TaskStatus, example: TaskStatus.PENDING })
  @Column({ type: 'enum', enum: TaskStatus, default: TaskStatus.PENDING })
  status: TaskStatus;

  @ApiProperty({ example: '2026-05-07T10:00:00.000Z' })
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ApiProperty({ example: '2026-05-07T12:00:00.000Z' })
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
