output "ecr_repository_url" {
    value = aws_ecr_repository.notify_slack.repository_url
}

output "ecs_cluster_name" {
    value = aws_ecs_cluster.main.name
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
