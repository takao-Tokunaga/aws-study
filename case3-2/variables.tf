variable "slack_webhook_url" {
    type      = string
    sensitive = true
    description = "Slack Incoming Webhook URL"
}

variable "schedule_expression" {
    type        = string
    default     = "cron(0 9 * * ? *)"
    description = "EventBridge schedule expression (default: every day at 9:00 JST)"
}

variable "slack_message" {
    type        = string
    default     = "Hello from AWS Step Functions!"
    description = "Message to send to Slack"
}
