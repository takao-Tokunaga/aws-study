import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  @Get()
  @ApiOperation({ summary: 'ヘルスチェック' })
  check() {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }
}
