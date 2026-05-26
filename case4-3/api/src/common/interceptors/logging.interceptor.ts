import {
  Injectable, NestInterceptor, ExecutionContext, CallHandler,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';

// すべてのリクエストをINFOレベルでログ出力する。
// CloudWatch Insights: filter level = "INFO" で正常系リクエストを確認できる。
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req   = context.switchToHttp().getRequest();
    const start = Date.now();

    return next.handle().pipe(
      tap(() => {
        const res = context.switchToHttp().getResponse();
        process.stdout.write(JSON.stringify({
          level:      'INFO',
          timestamp:  new Date().toISOString(),
          method:     req.method,
          path:       req.url,
          statusCode: res.statusCode,
          durationMs: Date.now() - start,
        }) + '\n');
      }),
    );
  }
}
