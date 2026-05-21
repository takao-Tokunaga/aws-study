import { Controller, Post, Get, Param, ParseIntPipe, HttpCode } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { ExportsService } from './exports.service';

@ApiTags('Exports')
@Controller('exports')
export class ExportsController {
  constructor(private readonly service: ExportsService) {}

  @Post()
  @HttpCode(201)
  @ApiOperation({ summary: 'CSV エクスポートジョブ作成' })
  create() {
    return this.service.createJob();
  }

  @Get(':id')
  @ApiOperation({ summary: 'エクスポートジョブ状態取得' })
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.service.getJob(id);
  }
}
