import {
  ExceptionFilter, Catch, ArgumentsHost,
  HttpException, HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';

// すべてのHTTP例外をキャッチし、CloudWatch Insightsで検索可能なJSON形式でログ出力する。
// filter level = "ERROR" でエラーログのみ抽出できる。
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx    = host.switchToHttp();
    const req    = ctx.getRequest<Request>();
    const res    = ctx.getResponse<Response>();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException
      ? (exception.getResponse() as any)?.message ?? exception.message
      : 'Internal server error';

    const logEntry = {
      level:     status >= 500 ? 'ERROR' : 'WARN',
      timestamp: new Date().toISOString(),
      path:      req.url,
      method:    req.method,
      statusCode: status,
      message:   Array.isArray(message) ? message.join(', ') : message,
      // 5xx のみスタックトレースを出力
      ...(status >= 500 && exception instanceof Error
        ? { stack: exception.stack }
        : {}),
    };

    // CloudWatch Logs に1行JSONとして書き込む
    process.stderr.write(JSON.stringify(logEntry) + '\n');

    res.status(status).json({ message: Array.isArray(message) ? message : [message] });
  }
}
