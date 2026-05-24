variable "project" {
  type    = string
  default = "takao-case4-1"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1c", "ap-northeast-1d"]
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "key_name" {
  type        = string
  description = "EC2 bastion key pair name"
}

variable "api_image" {
  type    = string
  default = "nginx:latest"
}
