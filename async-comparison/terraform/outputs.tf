output "ec2_queue_url"    { value = module.sqs.ec2_queue_url }
output "lambda_queue_url" { value = module.sqs.lambda_queue_url }
output "ecs_queue_url"    { value = module.sqs.ecs_queue_url }
output "ecr_repository_url" { value = module.ecs.ecr_repository_url }
