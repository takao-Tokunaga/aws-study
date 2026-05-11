# case2-1: ECS Fargate + RDS + CloudFront

タスク管理APIをECS Fargateで動かし、RDS MySQLをデータストアとして使用する構成。

## アーキテクチャ

```
Internet
  ↓
CloudFront
  ↓
ALB (パブリックサブネット)
  ↓
ECS Fargate × 2 (プライベートサブネット)
  ↓
RDS MySQL (DBサブネット)
```

## AWSリソース

| リソース | 内容 |
|---|---|
| VPC | 10.0.0.0/16 |
| サブネット | パブリック×2 / プライベート×2 / DB×2 |
| NAT Gateway | プライベートサブネットからECRへのアクセス用 |
| CloudFront | ALBをオリジンとしてキャッシュ |
| ALB | ECSへのロードバランシング |
| ECS Fargate | APIコンテナ (desired_count=2) |
| ECR | Dockerイメージ管理 |
| RDS | MySQL 8.0 (db.t3.micro) |
| Secrets Manager | DBパスワード管理 |

## アプリ仕様

Node.js (Express) によるREST API。

| メソッド | パス | 説明 |
|---|---|---|
| GET | /health | ヘルスチェック |
| GET | /api/tasks | タスク一覧 (`?status=pending\|in_progress\|done`) |
| GET | /api/tasks/:id | タスク取得 |
| POST | /api/tasks | タスク作成 |
| PUT | /api/tasks/:id | タスク更新 |
| DELETE | /api/tasks/:id | タスク削除 |

## デプロイ

### 初回

```bash
terraform init
terraform apply
```

ECRへのイメージプッシュ（linux/amd64で build）：

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin $ECR_URL

docker buildx build --platform linux/amd64 -t "${ECR_URL}:latest" ./app --push
```

### 以降（CD）

`case2-1/app/` 配下を変更して `main` ブランチにpushすると GitHub Actions が自動デプロイする。

ワークフロー: [.github/workflows/deploy-case2-1.yml](../.github/workflows/deploy-case2-1.yml)

## 削除

```bash
# Secrets Managerのシークレットを即時削除
aws secretsmanager delete-secret \
  --secret-id takao-case2-1/db-password \
  --force-delete-without-recovery \
  --profile default

terraform destroy
```
