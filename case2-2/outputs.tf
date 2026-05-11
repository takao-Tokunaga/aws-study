output "lambda_function_name" {
    value = aws_lambda_function.notify_slack.function_name
}

output "state_machine_arn" {
    value = aws_sfn_state_machine.notify.arn
}

output "scheduler_name" {
    value = aws_scheduler_schedule.notify.name
}

output "secret_name" {
    value = aws_secretsmanager_secret.slack_webhook.name
}
