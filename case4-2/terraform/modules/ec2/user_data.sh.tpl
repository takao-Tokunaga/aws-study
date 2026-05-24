#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# ─── Node.js 20 + git のインストール ───────────────────────────────────────────
dnf update -y
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs git

# ─── CloudWatch Agent のインストール ──────────────────────────────────────────
dnf install -y amazon-cloudwatch-agent

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CWAGENT'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/api.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S"
          }
        ]
      }
    }
  }
}
CWAGENT

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# ─── リポジトリのクローン ──────────────────────────────────────────────────────
git clone https://github.com/takao-Tokunaga/aws-study /app
cd /app/case4-2/api

# ─── 依存関係インストール & ビルド ─────────────────────────────────────────────
npm ci
npm run build

# ─── DB パスワードを SSM から取得 ──────────────────────────────────────────────
DB_PASSWORD=$(aws ssm get-parameter \
  --name "/${project}/db/password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region "${aws_region}")

# ─── 環境変数ファイルの作成 ────────────────────────────────────────────────────
cat > /app/case4-2/api/.env <<EOF
NODE_ENV=production
PORT=3000
DB_HOST=${db_host}
DB_PORT=5432
DB_NAME=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=$DB_PASSWORD
EOF
chmod 600 /app/case4-2/api/.env

# ─── systemd サービスの登録 ────────────────────────────────────────────────────
cat > /etc/systemd/system/api.service <<'SERVICE'
[Unit]
Description=NestJS REST API
After=network.target

[Service]
Type=simple
WorkingDirectory=/app/case4-2/api
ExecStart=/usr/bin/node dist/main.js
Restart=always
RestartSec=5
EnvironmentFile=/app/case4-2/api/.env
StandardOutput=append:/var/log/api.log
StandardError=append:/var/log/api.log

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable api
systemctl start api
