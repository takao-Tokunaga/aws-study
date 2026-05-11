data "archive_file" "notify_slack" {
    type        = "zip"
    source_file = "${path.module}/lambda_src/notify_slack.py"
    output_path = "${path.module}/lambda_src/notify_slack.zip"
}

resource "aws_lambda_function" "notify_slack" {
    function_name    = "case2-2-notify-slack"
    role             = aws_iam_role.lambda_exec.arn
    handler          = "notify_slack.lambda_handler"
    runtime          = "python3.12"
    filename         = data.archive_file.notify_slack.output_path
    source_code_hash = data.archive_file.notify_slack.output_base64sha256
    timeout          = 30

    environment {
        variables = {
            SLACK_WEBHOOK_SECRET_NAME = aws_secretsmanager_secret.slack_webhook.name
        }
    }
}
