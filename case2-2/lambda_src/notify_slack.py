import json
import urllib.request
import boto3
import os

def lambda_handler(event, context):
    secret_name = os.environ["SLACK_WEBHOOK_SECRET_NAME"]
    region      = os.environ["AWS_REGION"]

    client = boto3.client("secretsmanager", region_name=region)
    webhook_url = client.get_secret_value(SecretId=secret_name)["SecretString"]

    message = event.get("message", "Notification from AWS Step Functions")
    payload = json.dumps({"text": message}).encode("utf-8")

    req = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        body = resp.read().decode("utf-8")

    return {"statusCode": resp.status, "body": body}
