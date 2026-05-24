import boto3
import json
import time
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
log = logging.getLogger(__name__)

QUEUE_URL     = os.environ['SQS_QUEUE_URL']
SLEEP_SECONDS = int(os.environ.get('SLEEP_SECONDS', '5'))
REGION        = os.environ.get('AWS_REGION', 'ap-northeast-1')

sqs = boto3.client('sqs', region_name=REGION)
cw  = boto3.client('cloudwatch', region_name=REGION)


def put_metric(name: str, value: float, unit: str = 'Milliseconds'):
    cw.put_metric_data(
        Namespace='AsyncComparison',
        MetricData=[{
            'MetricName': name,
            'Dimensions': [{'Name': 'Environment', 'Value': 'ec2'}],
            'Value': value,
            'Unit': unit,
        }]
    )


def process(message: dict):
    start = time.time()
    body  = json.loads(message['Body'])
    log.info(f"処理開始: job_id={body.get('job_id')}")

    time.sleep(SLEEP_SECONDS)

    elapsed_ms = (time.time() - start) * 1000
    put_metric('ProcessingLatency', elapsed_ms)
    put_metric('ProcessedCount', 1, unit='Count')
    log.info(f"処理完了: {elapsed_ms:.1f}ms")


def poll():
    log.info(f"EC2 Worker 起動 (sleep={SLEEP_SECONDS}s)")
    while True:
        resp = sqs.receive_message(
            QueueUrl=QUEUE_URL,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=20,
        )
        for msg in resp.get('Messages', []):
            try:
                process(msg)
            except Exception as e:
                log.error(f"エラー: {e}")
            finally:
                sqs.delete_message(
                    QueueUrl=QUEUE_URL,
                    ReceiptHandle=msg['ReceiptHandle'],
                )


if __name__ == '__main__':
    poll()
