import boto3
import json
import time
import os
import logging

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

SLEEP_SECONDS = int(os.environ.get('SLEEP_SECONDS', '5'))
REGION        = os.environ.get('WORKER_REGION', 'ap-northeast-1')

cw = boto3.client('cloudwatch', region_name=REGION)


def put_metric(name: str, value: float, unit: str = 'Milliseconds'):
    cw.put_metric_data(
        Namespace='AsyncComparison',
        MetricData=[{
            'MetricName': name,
            'Dimensions': [{'Name': 'Environment', 'Value': 'lambda'}],
            'Value': value,
            'Unit': unit,
        }]
    )


def handler(event, context):
    for record in event['Records']:
        start = time.time()
        body  = json.loads(record['body'])
        log.info(f"処理開始: job_id={body.get('job_id')}")

        time.sleep(SLEEP_SECONDS)

        elapsed_ms = (time.time() - start) * 1000
        put_metric('ProcessingLatency', elapsed_ms)
        put_metric('ProcessedCount', 1, unit='Count')
        log.info(f"処理完了: {elapsed_ms:.1f}ms")

    return {'statusCode': 200}
