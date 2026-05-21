resource "aws_sqs_queue" "csv_export" {
  name                       = "${var.project}-csv-export"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20
  tags = { Name = "${var.project}-csv-export" }
}
