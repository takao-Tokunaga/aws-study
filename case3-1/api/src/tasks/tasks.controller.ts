import {
  Controller, Get, Post, Put, Delete,
  Param, Body, Query, ParseIntPipe, HttpCode,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { TasksService } from './tasks.service';
import { S3Service } from '../s3/s3.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task, TaskStatus } from './task.entity';

@ApiTags('Tasks')
@Controller('tasks')
export class TasksController {
  constructor(
    private readonly tasksService: TasksService,
    private readonly s3Service: S3Service,
  ) {}

  @Get()
  @ApiOperation({ summary: 'タスク一覧の取得' })
  @ApiQuery({ name: 'status', enum: TaskStatus, required: false })
  @ApiResponse({ status: 200, type: [Task] })
  findAll(@Query('status') status?: TaskStatus) {
    return this.tasksService.findAll(status);
  }

  @Get(':id')
  @ApiOperation({ summary: 'タスクの取得' })
  @ApiResponse({ status: 200, type: Task })
  @ApiResponse({ status: 404, description: 'タスクが見つからない' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.tasksService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'タスクの作成' })
  @ApiResponse({ status: 201, type: Task })
  @ApiResponse({ status: 400, description: 'バリデーションエラー' })
  create(@Body() dto: CreateTaskDto) {
    return this.tasksService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'タスクの更新' })
  @ApiResponse({ status: 200, type: Task })
  @ApiResponse({ status: 404, description: 'タスクが見つからない' })
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateTaskDto) {
    return this.tasksService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(204)
  @ApiOperation({ summary: 'タスクの削除' })
  @ApiResponse({ status: 204, description: '削除成功' })
  @ApiResponse({ status: 404, description: 'タスクが見つからない' })
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.tasksService.remove(id);
  }

  @Post('upload-url')
  @ApiOperation({ summary: '画像アップロード用 presigned URL 発行' })
  @ApiResponse({ status: 201, schema: { properties: { uploadUrl: { type: 'string' }, key: { type: 'string' } } } })
  async getUploadUrl(@Body('filename') filename: string) {
    const key = `images/tasks/${Date.now()}-${filename}`;
    const uploadUrl = await this.s3Service.getPresignedUploadUrl(key);
    return { uploadUrl, key };
  }
}
