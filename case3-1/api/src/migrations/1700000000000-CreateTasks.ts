import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateTasks1700000000000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "tasks_status_enum" AS ENUM ('pending', 'in_progress', 'done')
    `);

    await queryRunner.query(`
      CREATE TABLE "tasks" (
        "id"              SERIAL PRIMARY KEY,
        "title"           VARCHAR(255) NOT NULL,
        "description"     TEXT,
        "status"          "tasks_status_enum" NOT NULL DEFAULT 'pending',
        "picture_s3_key"  VARCHAR(500),
        "created_at"      TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at"      TIMESTAMP NOT NULL DEFAULT now()
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "tasks"`);
    await queryRunner.query(`DROP TYPE "tasks_status_enum"`);
  }
}
