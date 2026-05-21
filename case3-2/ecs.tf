resource "aws_ecs_cluster" "main" {
    name = "case3-2-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
    name              = "/ecs/case3-2-notify-slack"
    retention_in_days = 7
}

resource "aws_ecs_task_definition" "notify_slack" {
    family                   = "case3-2-notify-slack"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = aws_iam_role.ecs_task_execution.arn
    task_role_arn            = aws_iam_role.ecs_task.arn

    container_definitions = jsonencode([{
        name      = "notify-slack"
        image     = "${aws_ecr_repository.notify_slack.repository_url}:latest"
        essential = true

        environment = [{
            name  = "SLACK_WEBHOOK_SECRET_NAME"
            value = aws_secretsmanager_secret.slack_webhook.name
        }]

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
                "awslogs-region"        = "ap-northeast-1"
                "awslogs-stream-prefix" = "ecs"
            }
        }
    }])
}
