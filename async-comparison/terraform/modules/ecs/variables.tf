variable "project"               { type = string }
variable "aws_region"            { type = string }
variable "sqs_queue_url"         { type = string }
variable "sleep_seconds"         { type = number }
variable "ecs_execution_role_arn" { type = string }
variable "ecs_task_role_arn"     { type = string }
