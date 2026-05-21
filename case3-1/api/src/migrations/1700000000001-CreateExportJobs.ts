import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateExportJobs1700000000001 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE export_jobs (
        id SERIAL PRIMARY KEY,
        status VARCHAR(20) NOT NULL DEFAULT 'pending',
        s3_key VARCHAR(500),
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE export_jobs`);
  }
}
