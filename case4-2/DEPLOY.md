# case4-2 デプロイ手順

## アーキテクチャ

```
Internet → CloudFront → ALB → EC2 (NestJS API) → RDS (PostgreSQL)
                                    ↑
                              踏み台EC2 (migration用)
```

## 前提条件

- AWS CLI 設定済み (`aws configure`)
- Terraform インストール済み
- GitHub リポジトリの Secrets 設定権限あり

---

## 1. キーペアの作成

```bash
aws ec2 create-key-pair \
  --key-name case4-2-bastion \
  --region ap-northeast-1 \
  --query "KeyMaterial" \
  --output text > ~/case4-2-bastion.pem

chmod 400 ~/case4-2-bastion.pem
```

---

## 2. terraform.tfvars の設定

`case4-2/terraform/terraform.tfvars` に以下を記載：

```hcl
project    = "takao-case4-2"
aws_region = "ap-northeast-1"
key_name   = "case4-2-bastion"

db_password       = "<DBパスワード>"
slack_webhook_url = "<Slack Webhook URL>"
```

---

## 3. Terraform apply

```bash
cd case4-2/terraform
terraform init
terraform apply
```

完了後、以下の値を記録しておく：

```bash
terraform output
# cloudfront_domain → API アクセス URL
# bastion_public_ip → migration 用
# rds_endpoint      → migration 用
# deploy_role_arn   → GitHub Secret に設定
```

---

## 4. GitHub Secret の設定

GitHub → リポジトリ → Settings → Secrets and variables → Actions

| Secret名 | 値 |
|---|---|
| `AWS_DEPLOY_ROLE_ARN_CASE4_2` | `terraform output deploy_role_arn` の値 |

---

## 5. 踏み台経由でマイグレーション実行

```bash
# 踏み台に SSH
ssh -i ~/case4-2-bastion.pem ec2-user@<bastion_public_ip>

# 踏み台の中で実行
git clone https://github.com/takao-Tokunaga/aws-study /tmp/app
cd /tmp/app/case4-2/api
npm ci && npm run build

NODE_ENV=production \
DB_HOST=<rds_endpoint> \
DB_PORT=5432 \
DB_NAME=taskdb \
DB_USERNAME=postgres \
DB_PASSWORD=<db_password> \
npm run migration:run

exit
```

---

## 6. 動作確認

```bash
# ヘルスチェック
curl https://<cloudfront_domain>/api/health
# → {"status":"ok","timestamp":"..."}

# タスク作成
curl -X POST https://<cloudfront_domain>/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"テスト","description":"動作確認"}'
```

---

## 7. CD の動作確認

`case4-2/api/` 以下を変更して main ブランチにpushすると、GitHub Actions が自動でデプロイします。

```
push → OIDC認証 → SSM Run Command → EC2内で
                                      git pull origin main
                                      npm ci && npm run build
                                      systemctl restart api
```

GitHub Actions のログは `.github/workflows/deploy-case4-2-api.yml` を参照。

---

## トラブルシューティング

### terraform apply でキーペアエラー
```
Error: InvalidKeyPair.NotFound: The key pair 'case4-2-bastion' does not exist
```
→ 手順 1 のキーペア作成を先に行う。

### migration 実行時に SSL エラー
```
error: no pg_hba.conf entry for host ... no encryption
```
→ `NODE_ENV=production` を付けて実行する（SSL が有効になる）。

### API が 502 を返す
EC2 の起動直後は user_data が実行中の場合がある。SSM で状態確認：

```bash
aws ssm send-command \
  --instance-ids <ec2_instance_id> \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["systemctl status api --no-pager"]' \
  --region ap-northeast-1
```

---

## リソース削除

```bash
cd case4-2/terraform
terraform destroy
```
