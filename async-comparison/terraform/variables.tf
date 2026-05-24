variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project" {
  type    = string
  default = "async-comparison"
}

variable "sleep_seconds" {
  description = "ダミー処理のスリープ秒数"
  type        = number
  default     = 5
}

variable "message_count" {
  description = "ベンチマーク1回あたりのメッセージ数"
  type        = number
  default     = 100
}
