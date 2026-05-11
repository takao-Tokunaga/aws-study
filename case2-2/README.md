# case2-2: EventBridge → Step Functions → ECS → Slack通知

EventBridge Schedulerで定期実行し、Step Functions経由でECSコンテナを起動してSlackに通知する構成。

## アーキテクチャ

```
EventBridge Scheduler (毎日 9:00 JST)
  ↓
Step Functions
  ↓
ECS Fargate (ワンショット実行)
  ↓ (Secrets Managerから Webhook URL を取得)
Slack
```

## AWSリソース

| リソース | 内容 |
|---|---|
| EventBridge Scheduler | cron式でStep Functionsを定期起動 |
| Step Functions | ECS RunTask.sync でコンテナを実行 |
| ECS Fargate | Slackへ通知するPythonコンテナ |
| ECR | Dockerイメージ管理 |
| Secrets Manager | Slack Webhook URL管理 |
| CloudWatch Logs | ECSコンテナのログ (`/ecs/case2-2-notify-slack`) |

## ファイル構成

```
case2-2/
├── provider.tf         # AWS provider、S3 backend
├── variables.tf        # 変数定義
├── terraform.tfvars    # 変数値
├── network.tf          # デフォルトVPC参照
├── ecr.tf              # ECRリポジトリ
├── ecs.tf              # ECSクラスター・タスク定義
├── stepfunctions.tf    # Step Functionsステートマシン
├── eventbridge.tf      # EventBridge Scheduler
├── iam.tf              # IAMロール
├── secrets.tf          # Secrets Manager
├── outputs.tf          # 出力値
└── app/
    ├── notify_slack.py # Slack通知スクリプト
    └── Dockerfile
```

## デプロイ

### 1. Slack Webhook URLを設定

`terraform.tfvars` の `slack_webhook_url` を実際のURLに変更する。

### 2. Terraformでインフラを作成

```bash
terraform init
terraform apply
```

### 3. DockerイメージをビルドしてECRにプッシュ

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin $ECR_URL

# Apple Silicon Macの場合は --platform linux/amd64 が必要
docker buildx build --platform linux/amd64 -t "${ECR_URL}:latest" ./app --push
```

### 4. 動作確認（手動実行）

```bash
aws stepfunctions start-execution \
  --state-machine-arn $(terraform output -raw state_machine_arn) \
  --input '{"message": "テスト通知"}' \
  --profile default
```

## スケジュール変更

`terraform.tfvars` の `schedule_expression` を変更して `terraform apply`。

```
cron(分 時 日 月 曜日 年)  ※ タイムゾーンはAsia/Tokyo
```

例：
- 毎日9時: `cron(0 9 * * ? *)`
- 毎週月曜9時: `cron(0 9 ? * MON *)`

## 削除

```bash
# ECRのイメージを先に削除
aws ecr batch-delete-image \
  --repository-name case2-2-notify-slack \
  --image-ids "$(aws ecr list-images --repository-name case2-2-notify-slack --profile default --query 'imageIds[*]' --output json)" \
  --profile default

terraform destroy
```
