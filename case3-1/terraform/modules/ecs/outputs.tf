output "cluster_name"              { value = aws_ecs_cluster.main.name }
output "cluster_arn"               { value = aws_ecs_cluster.main.arn }
output "api_service_name"          { value = aws_ecs_service.api.name }
output "frontend_service_name"     { value = aws_ecs_service.frontend.name }
output "api_task_definition_arn"   { value = aws_ecs_task_definition.api.arn }
output "api_task_role_arn"         { value = aws_iam_role.api_task.arn }
