import json
import urllib.request
import boto3
import os

def main():
    secret_name = os.environ["SLACK_WEBHOOK_SECRET_NAME"]
    region      = os.environ.get("AWS_DEFAULT_REGION", "ap-northeast-1")
    message     = os.environ.get("MESSAGE", "Notification from AWS ECS")

    client = boto3.client("secretsmanager", region_name=region)
    webhook_url = client.get_secret_value(SecretId=secret_name)["SecretString"]

    payload = json.dumps({"text": message}).encode("utf-8")
    req = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        print(f"Slack response: {resp.status}")

if __name__ == "__main__":
    main()
