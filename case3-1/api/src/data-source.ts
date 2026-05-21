import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { Task } from './tasks/task.entity';
import { ExportJob } from './exports/export-job.entity';

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT ?? '5432'),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  entities: [Task, ExportJob],
  migrations: ['dist/migrations/*.js'],
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});
