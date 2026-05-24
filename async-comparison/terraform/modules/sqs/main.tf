resource "aws_sqs_queue" "ec2" {
  name                       = "${var.project}-ec2"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 3600
  receive_wait_time_seconds  = 20
  tags = { Name = "${var.project}-ec2" }
}

resource "aws_sqs_queue" "lambda" {
  name                       = "${var.project}-lambda"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 3600
  receive_wait_time_seconds  = 20
  tags = { Name = "${var.project}-lambda" }
}

resource "aws_sqs_queue" "ecs" {
  name                       = "${var.project}-ecs"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 3600
  receive_wait_time_seconds  = 20
  tags = { Name = "${var.project}-ecs" }
}
