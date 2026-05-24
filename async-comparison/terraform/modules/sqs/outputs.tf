output "ec2_queue_url"    { value = aws_sqs_queue.ec2.url }
output "ec2_queue_arn"    { value = aws_sqs_queue.ec2.arn }
output "lambda_queue_url" { value = aws_sqs_queue.lambda.url }
output "lambda_queue_arn" { value = aws_sqs_queue.lambda.arn }
output "ecs_queue_url"    { value = aws_sqs_queue.ecs.url }
output "ecs_queue_arn"    { value = aws_sqs_queue.ecs.arn }
