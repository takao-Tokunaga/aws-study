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
exports.TasksController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const tasks_service_1 = require("./tasks.service");
const s3_service_1 = require("../s3/s3.service");
const create_task_dto_1 = require("./dto/create-task.dto");
const update_task_dto_1 = require("./dto/update-task.dto");
const task_entity_1 = require("./task.entity");
let TasksController = class TasksController {
    constructor(tasksService, s3Service) {
        this.tasksService = tasksService;
        this.s3Service = s3Service;
    }
    findAll(status) {
        return this.tasksService.findAll(status);
    }
    findOne(id) {
        return this.tasksService.findOne(id);
    }
    create(dto) {
        return this.tasksService.create(dto);
    }
    update(id, dto) {
        return this.tasksService.update(id, dto);
    }
    remove(id) {
        return this.tasksService.remove(id);
    }
    async getUploadUrl(filename) {
        const key = `tasks/${Date.now()}-${filename}`;
        const uploadUrl = await this.s3Service.getPresignedUploadUrl(key);
        return { uploadUrl, key };
    }
};
exports.TasksController = TasksController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'タスク一覧の取得' }),
    (0, swagger_1.ApiQuery)({ name: 'status', enum: task_entity_1.TaskStatus, required: false }),
    (0, swagger_1.ApiResponse)({ status: 200, type: [task_entity_1.Task] }),
    __param(0, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], TasksController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'タスクの取得' }),
    (0, swagger_1.ApiResponse)({ status: 200, type: task_entity_1.Task }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'タスクが見つからない' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], TasksController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'タスクの作成' }),
    (0, swagger_1.ApiResponse)({ status: 201, type: task_entity_1.Task }),
    (0, swagger_1.ApiResponse)({ status: 400, description: 'バリデーションエラー' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_task_dto_1.CreateTaskDto]),
    __metadata("design:returntype", void 0)
], TasksController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'タスクの更新' }),
    (0, swagger_1.ApiResponse)({ status: 200, type: task_entity_1.Task }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'タスクが見つからない' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_task_dto_1.UpdateTaskDto]),
    __metadata("design:returntype", void 0)
], TasksController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(204),
    (0, swagger_1.ApiOperation)({ summary: 'タスクの削除' }),
    (0, swagger_1.ApiResponse)({ status: 204, description: '削除成功' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'タスクが見つからない' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], TasksController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)('upload-url'),
    (0, swagger_1.ApiOperation)({ summary: '画像アップロード用 presigned URL 発行' }),
    (0, swagger_1.ApiResponse)({ status: 201, schema: { properties: { uploadUrl: { type: 'string' }, key: { type: 'string' } } } }),
    __param(0, (0, common_1.Body)('filename')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TasksController.prototype, "getUploadUrl", null);
exports.TasksController = TasksController = __decorate([
    (0, swagger_1.ApiTags)('Tasks'),
    (0, common_1.Controller)('tasks'),
    __metadata("design:paramtypes", [tasks_service_1.TasksService,
        s3_service_1.S3Service])
], TasksController);
//# sourceMappingURL=tasks.controller.js.map