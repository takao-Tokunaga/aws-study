import json
import os
import urllib.request
import boto3

SLACK_WEBHOOK_SECRET_NAME = os.environ['SLACK_WEBHOOK_SECRET_NAME']

def get_webhook_url():
    client = boto3.client('secretsmanager')
    resp = client.get_secret_value(SecretId=SLACK_WEBHOOK_SECRET_NAME)
    return json.loads(resp['SecretString'])['webhook_url']

def handler(event, context):
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])

    alarm_name  = sns_message.get('AlarmName', 'Unknown')
    state       = sns_message.get('NewStateValue', 'Unknown')
    reason      = sns_message.get('NewStateReason', '')
    timestamp   = sns_message.get('StateChangeTime', '')

    emoji = ':red_circle:' if state == 'ALARM' else ':large_green_circle:'
    text = (
        f"{emoji} *CloudWatch Alarm*\n"
        f"*アラーム名:* {alarm_name}\n"
        f"*状態:* {state}\n"
        f"*理由:* {reason}\n"
        f"*時刻:* {timestamp}"
    )

    webhook_url = get_webhook_url()
    payload = json.dumps({'text': text}).encode('utf-8')
    req = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={'Content-Type': 'application/json'},
        method='POST',
    )
    urllib.request.urlopen(req)
    return {'statusCode': 200}
