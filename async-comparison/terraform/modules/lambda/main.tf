data "archive_file" "handler" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/handler.py"
  output_path = "${path.module}/handler.zip"
}

resource "aws_lambda_function" "worker" {
  function_name    = "${var.project}-lambda-worker"
  role             = var.lambda_role_arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  timeout          = 60
  filename         = data.archive_file.handler.output_path
  source_code_hash = data.archive_file.handler.output_base64sha256

  environment {
    variables = {
      SLEEP_SECONDS = tostring(var.sleep_seconds)
      WORKER_REGION = var.aws_region
    }
  }

  tags = { Name = "${var.project}-lambda-worker" }
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.worker.arn
  batch_size       = 1
  enabled          = true
}
