"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppDataSource = void 0;
require("reflect-metadata");
const typeorm_1 = require("typeorm");
const task_entity_1 = require("./tasks/task.entity");
exports.AppDataSource = new typeorm_1.DataSource({
    type: 'postgres',
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT ?? '5432'),
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    entities: [task_entity_1.Task],
    migrations: ['dist/migrations/*.js'],
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});
//# sourceMappingURL=data-source.js.map