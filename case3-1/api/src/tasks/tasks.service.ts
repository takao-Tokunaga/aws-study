import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task, TaskStatus } from './task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { S3Service } from '../s3/s3.service';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private readonly repo: Repository<Task>,
    private readonly s3: S3Service,
  ) {}

  async findAll(status?: TaskStatus): Promise<Task[]> {
    const where = status ? { status } : {};
    const tasks = await this.repo.find({ where, order: { createdAt: 'DESC' } });
    return Promise.all(tasks.map(t => this.withPictureUrl(t)));
  }

  async findOne(id: number): Promise<Task> {
    const task = await this.repo.findOne({ where: { id } });
    if (!task) throw new NotFoundException(`Task ${id} not found`);
    return this.withPictureUrl(task);
  }

  async create(dto: CreateTaskDto): Promise<Task> {
    const task = this.repo.create(dto);
    return this.repo.save(task);
  }

  async update(id: number, dto: UpdateTaskDto): Promise<Task> {
    const task = await this.repo.findOne({ where: { id } });
    if (!task) throw new NotFoundException(`Task ${id} not found`);
    Object.assign(task, dto);
    const saved = await this.repo.save(task);
    return this.withPictureUrl(saved);
  }

  async remove(id: number): Promise<void> {
    const task = await this.repo.findOne({ where: { id } });
    if (!task) throw new NotFoundException(`Task ${id} not found`);
    if (task.pictureS3Key) {
      await this.s3.deleteObject(task.pictureS3Key).catch(() => {});
    }
    await this.repo.delete(id);
  }

  private async withPictureUrl(task: Task): Promise<Task> {
    if (!task.pictureS3Key) return task;
    task.pictureUrl = await this.s3.getSignedUrl(task.pictureS3Key);
    return task;
  }
}
