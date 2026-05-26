import { IsString, IsOptional, IsEnum, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { TaskStatus } from '../task.entity';

export class UpdateTaskDto {
  @ApiProperty({ example: 'ミーティング資料を準備する' })
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiProperty({ required: false, example: '月次報告会議のスライドを作成する' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ enum: TaskStatus, required: false })
  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;
}
