resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/async-comparison/ec2"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/async-comparison/lambda"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-benchmark"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "処理レイテンシ比較 (ms)"
          region = var.aws_region
          period = 60
          stat   = "Average"
          metrics = [
            ["AsyncComparison", "ProcessingLatency", "Environment", "ec2"],
            ["AsyncComparison", "ProcessingLatency", "Environment", "lambda"],
            ["AsyncComparison", "ProcessingLatency", "Environment", "ecs"]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "処理件数"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AsyncComparison", "ProcessedCount", "Environment", "ec2"],
            ["AsyncComparison", "ProcessedCount", "Environment", "lambda"],
            ["AsyncComparison", "ProcessedCount", "Environment", "ecs"]
          ]
        }
      }
    ]
  })
}
