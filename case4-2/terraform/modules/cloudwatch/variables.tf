variable "project"            { type = string }
variable "aws_region"         { type = string }
variable "ec2_instance_id"    { type = string }
variable "api_log_group_name" { type = string }
variable "slack_webhook_url" {
  type      = string
  sensitive = true
}
variable "lambda_role_arn"   { type = string }

variable "cpu_alarm_threshold" {
  type    = number
  default = 1
}
