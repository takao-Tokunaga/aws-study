output "ecr_repository_url" { value = aws_ecr_repository.worker.repository_url }
output "cluster_name"       { value = aws_ecs_cluster.main.name }
output "service_name"       { value = aws_ecs_service.worker.name }
