output "queue_url" {
  value = aws_sqs_queue.csv_export.url
}
output "queue_arn" {
  value = aws_sqs_queue.csv_export.arn
}
output "queue_name" {
  value = aws_sqs_queue.csv_export.name
}
