variable "project"           { type = string }
variable "aws_region"        { type = string }
variable "ecs_cluster_name"  { type = string }
variable "ecs_service_name"  { type = string }
variable "slack_webhook_url" {
  type      = string
  sensitive = true
}
variable "lambda_role_arn"   { type = string }

# CPU使用率のアラーム閾値(%)。学習環境では低い値にしてアラームを発火させやすくする。
variable "cpu_alarm_threshold" {
  type    = number
  default = 1
}
