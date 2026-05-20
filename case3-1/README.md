# Case 3-1: CloudFront + ALB + ECS + RDS タスク管理アプリ

## アーキテクチャ

```
Internet
  │
  ▼
CloudFront (WAF)
  ├── /* ──────────────► External ALB → Frontend ECS (Next.js :3001)
  ├── /api/* ──────────► External ALB → API ECS (NestJS :3000)
  └── /images/* ───────► S3 (KMS暗号化, OAC, Signed URL)
                             ▲
                         Internal ALB
                             ▲
                    Frontend ECS → API ECS (サーバーサイドリクエスト)

API ECS ──► RDS (PostgreSQL)
API ECS ──► S3 (presigned URL 発行 / 削除)

EC2 Bastion ──► RDS (migration用)
```

## ディレクトリ構成

```
case3-1/
├── .github/workflows/
│   ├── deploy-api.yml       # API CD
│   └── deploy-frontend.yml  # Frontend CD
├── api/                     # NestJS REST API
│   ├── Dockerfile
│   └── src/
│       ├── tasks/           # タスク CRUD
│       ├── s3/              # S3 presigned URL / CloudFront Signed URL
│       └── migrations/      # DBマイグレーション
├── frontend/                # Next.js フロントエンド
│   ├── Dockerfile
│   └── src/app/tasks/       # タスク一覧・登録画面
└── terraform/
    ├── main.tf
    ├── modules/
    │   ├── vpc/             # VPC, subnet, NAT
    │   ├── ecr/             # ECR リポジトリ
    │   ├── security_groups/ # SG 一元管理
    │   ├── alb/             # External ALB + Internal ALB
    │   ├── ecs/             # ECS Cluster / Service / Task Definition
    │   ├── rds/             # PostgreSQL RDS
    │   ├── bastion/         # EC2 踏み台
    │   ├── s3/              # 暗号化 S3 バケット
    │   ├── cloudfront/      # CloudFront + OAC + Key Group
    │   └── waf/             # WAF (メンテナンスモード対応)
    └── github_actions_iam.tf # OIDC デプロイロール
```

## セットアップ手順

### 1. Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集

# CloudFront Signed URL 用鍵ペア生成
openssl genrsa -out private_key.pem 2048
openssl rsa -pubout -in private_key.pem -out public_key.pem

terraform init
terraform apply
```

### 2. ECR に初期イメージをプッシュ

```bash
# API
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-northeast-1.amazonaws.com
docker build -t case3-1-api ./api
docker tag case3-1-api:latest <ECR_URL>:latest
docker push <ECR_URL>:latest
```

### 3. RDS マイグレーション (Bastion経由)

```bash
# SSHトンネル
ssh -L 5432:<RDS_ENDPOINT>:5432 ec2-user@<BASTION_IP> -i ~/.ssh/case3-1-key.pem -N

# マイグレーション実行
cd api
DB_HOST=localhost DB_PORT=5432 DB_USERNAME=postgres DB_PASSWORD=xxx DB_NAME=taskdb \
  npm run migration:run
```

### 4. GitHub Actions シークレット設定

| シークレット名 | 値 |
|---|---|
| `AWS_DEPLOY_ROLE_ARN` | Terraform output: `github_actions_role_arn` |
| `CLOUDFRONT_URL` | `https://<distribution-domain>` |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront ディストリビューション ID |

### 5. WAF メンテナンスモード

```bash
# メンテナンス ON
terraform apply -var="maintenance_mode=true" -var='maintenance_allowed_cidrs=["YOUR_IP/32"]'

# メンテナンス OFF
terraform apply -var="maintenance_mode=false"
```

## API エンドポイント

| Method | Path | 説明 |
|--------|------|------|
| GET    | /api/tasks | タスク一覧 (picture_url付き) |
| GET    | /api/tasks/:id | タスク詳細 |
| POST   | /api/tasks | タスク作成 |
| PATCH  | /api/tasks/:id | タスク更新 |
| DELETE | /api/tasks/:id | タスク削除 |
| POST   | /api/tasks/upload-url | 画像アップロード用 presigned URL 発行 |
| GET    | /api/health | ヘルスチェック |
| GET    | /api/docs | Swagger UI |

## 画像フロー

### アップロード
```
Frontend → POST /api/tasks/upload-url
         ← { uploadUrl, key }  (S3 presigned PUT URL, 5分有効)
Frontend → PUT <uploadUrl> (S3 直接アップロード, KMS暗号化)
Frontend → POST /api/tasks { picture_s3_key: key }
```

### 取得
```
GET /api/tasks → picture_url: CloudFront Signed URL (1時間有効)
Frontend → GET <picture_url>
         → CloudFront → Private S3
```
