data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# EC2 API インスタンスロール
resource "aws_iam_role" "api_instance" {
  name               = "${var.project}-api-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# SSM Session Manager + Run Command (CD デプロイ用)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.api_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Agent (メトリクス・ログ送信)
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.api_instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM Parameter Store から DB パスワード取得
resource "aws_iam_role_policy" "ssm_params" {
  name = "${var.project}-api-ssm-params"
  role = aws_iam_role.api_instance.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters"]
      Resource = "arn:aws:ssm:*:*:parameter/${var.project}/*"
    }]
  })
}

resource "aws_iam_instance_profile" "api" {
  name = "${var.project}-api-instance-profile"
  role = aws_iam_role.api_instance.name
}

# Lambda ロール (Slack 通知)
resource "aws_iam_role" "lambda" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets" {
  name = "${var.project}-lambda-secrets"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:*:*:secret:${var.project}/*"
    }]
  })
}
