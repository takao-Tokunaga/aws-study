"""
ベンチマーク用メッセージ一括送信スクリプト
使い方: python send_messages.py --env ec2 --count 100
"""
import boto3
import json
import argparse
import uuid
import time

parser = argparse.ArgumentParser()
parser.add_argument('--env',   required=True, choices=['ec2', 'lambda', 'ecs'])
parser.add_argument('--count', type=int, default=100)
parser.add_argument('--queue-url', required=True)
args = parser.parse_args()

sqs   = boto3.client('sqs', region_name='ap-northeast-1')
start = time.time()

for i in range(args.count):
    sqs.send_message(
        QueueUrl=args.queue_url,
        MessageBody=json.dumps({
            'job_id':      str(uuid.uuid4()),
            'environment': args.env,
            'index':       i,
            'sent_at':     time.time(),
        })
    )
    if (i + 1) % 10 == 0:
        print(f"{i + 1}/{args.count} 送信済み")

print(f"完了: {args.count}件を{time.time()-start:.1f}秒で送信")
