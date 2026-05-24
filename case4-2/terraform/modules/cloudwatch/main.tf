# ─── Secrets Manager (Slack Webhook URL) ──────────────────────────────────────
resource "aws_secretsmanager_secret" "slack_webhook" {
  name                    = "${var.project}/slack-webhook-url"
  recovery_window_in_days = 0
  tags                    = { Name = "${var.project}-slack-webhook" }
}

resource "aws_secretsmanager_secret_version" "slack_webhook" {
  secret_id     = aws_secretsmanager_secret.slack_webhook.id
  secret_string = jsonencode({ webhook_url = var.slack_webhook_url })
}

# ─── CloudWatch Logs Group (EC2 API ログ) ─────────────────────────────────────
resource "aws_cloudwatch_log_group" "api" {
  name              = var.api_log_group_name
  retention_in_days = 30
  tags              = { Name = "${var.project}-api-logs" }
}

# ─── CloudWatch Insights Saved Query ──────────────────────────────────────────
resource "aws_cloudwatch_query_definition" "error_logs" {
  name = "${var.project}/error-logs"

  log_group_names = [aws_cloudwatch_log_group.api.name]

  query_string = <<-EOT
    fields @timestamp, level, method, path, statusCode, message
    | filter level = "ERROR" or level = "WARN"
    | sort @timestamp desc
    | limit 50
  EOT
}

# ─── SNS Topic ────────────────────────────────────────────────────────────────
resource "aws_sns_topic" "alarm" {
  name = "${var.project}-alarm"
  tags = { Name = "${var.project}-alarm" }
}

# ─── Lambda (Slack 通知) ───────────────────────────────────────────────────────
data "archive_file" "slack_notify" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/slack_notify/handler.py"
  output_path = "${path.module}/slack_notify.zip"
}

resource "aws_lambda_function" "slack_notify" {
  function_name    = "${var.project}-slack-notify"
  role             = var.lambda_role_arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  timeout          = 30
  filename         = data.archive_file.slack_notify.output_path
  source_code_hash = data.archive_file.slack_notify.output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_SECRET_NAME = aws_secretsmanager_secret.slack_webhook.name
    }
  }

  tags = { Name = "${var.project}-slack-notify" }
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notify.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notify.arn
}

# ─── CloudWatch Alarm (EC2 CPU 使用率) ────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.project}-ec2-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "EC2 API CPU 使用率が ${var.cpu_alarm_threshold}% 以上になりました"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = { Name = "${var.project}-ec2-cpu-alarm" }
}

# ─── CloudWatch Alarm (EC2 StatusCheck 失敗) ──────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  alarm_name          = "${var.project}-ec2-status-check"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "EC2 ステータスチェックに失敗しました"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = { Name = "${var.project}-ec2-status-alarm" }
}
