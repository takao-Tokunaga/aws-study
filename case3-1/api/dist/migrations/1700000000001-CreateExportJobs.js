"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreateExportJobs1700000000001 = void 0;
class CreateExportJobs1700000000001 {
    async up(queryRunner) {
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
    async down(queryRunner) {
        await queryRunner.query(`DROP TABLE export_jobs`);
    }
}
exports.CreateExportJobs1700000000001 = CreateExportJobs1700000000001;
