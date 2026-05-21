resource "aws_secretsmanager_secret" "slack_webhook" {
    name                    = "case3-2/slack-webhook-url"
    recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "slack_webhook" {
    secret_id     = aws_secretsmanager_secret.slack_webhook.id
    secret_string = var.slack_webhook_url
}
