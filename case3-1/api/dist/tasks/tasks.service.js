"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TasksService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const task_entity_1 = require("./task.entity");
const s3_service_1 = require("../s3/s3.service");
let TasksService = class TasksService {
    constructor(repo, s3) {
        this.repo = repo;
        this.s3 = s3;
    }
    async findAll(status) {
        const where = status ? { status } : {};
        const tasks = await this.repo.find({ where, order: { createdAt: 'DESC' } });
        return Promise.all(tasks.map(t => this.withPictureUrl(t)));
    }
    async findOne(id) {
        const task = await this.repo.findOne({ where: { id } });
        if (!task)
            throw new common_1.NotFoundException(`Task ${id} not found`);
        return this.withPictureUrl(task);
    }
    async create(dto) {
        const task = this.repo.create(dto);
        return this.repo.save(task);
    }
    async update(id, dto) {
        const task = await this.repo.findOne({ where: { id } });
        if (!task)
            throw new common_1.NotFoundException(`Task ${id} not found`);
        Object.assign(task, dto);
        const saved = await this.repo.save(task);
        return this.withPictureUrl(saved);
    }
    async remove(id) {
        const task = await this.repo.findOne({ where: { id } });
        if (!task)
            throw new common_1.NotFoundException(`Task ${id} not found`);
        if (task.pictureS3Key) {
            await this.s3.deleteObject(task.pictureS3Key).catch(() => { });
        }
        await this.repo.delete(id);
    }
    async withPictureUrl(task) {
        if (!task.pictureS3Key)
            return task;
        task.pictureUrl = await this.s3.getSignedUrl(task.pictureS3Key);
        return task;
    }
};
exports.TasksService = TasksService;
exports.TasksService = TasksService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(task_entity_1.Task)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        s3_service_1.S3Service])
], TasksService);
