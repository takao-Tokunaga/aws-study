output "ec2_instance_profile_name" { value = aws_iam_instance_profile.ec2.name }
output "lambda_role_arn"           { value = aws_iam_role.lambda.arn }
output "ecs_execution_role_arn"    { value = aws_iam_role.ecs_execution.arn }
output "ecs_task_role_arn"         { value = aws_iam_role.ecs_task.arn }
