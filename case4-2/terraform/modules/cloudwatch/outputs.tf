output "sns_topic_arn"     { value = aws_sns_topic.alarm.arn }
output "alarm_name"        { value = aws_cloudwatch_metric_alarm.ec2_cpu.alarm_name }
output "slack_secret_name" { value = aws_secretsmanager_secret.slack_webhook.name }
output "log_group_name"    { value = aws_cloudwatch_log_group.api.name }
