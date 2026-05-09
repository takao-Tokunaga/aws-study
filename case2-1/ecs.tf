resource "aws_ecs_cluster" "main" {
    name = "takao-case2-1-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
    name              = "/ecs/takao-case2-1-api"
    retention_in_days = 7
}

resource "aws_ecs_task_definition" "api" {
    family                   = "takao-case2-1-api"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "ARM64"
    }

    container_definitions = jsonencode([{
        name  = "api"
        image = "${aws_ecr_repository.api.repository_url}:latest"
        portMappings = [{
            containerPort = 3000
            protocol      = "tcp"
        }]
        environment = [
            { name = "DB_HOST", value = aws_db_instance.main.address },
            { name = "DB_NAME", value = "taskdb" },
            { name = "DB_USER", value = "apiuser" },
            { name = "PORT",    value = "3000" }
        ]
        secrets = [{
            name      = "DB_PASSWORD"
            valueFrom = aws_secretsmanager_secret.db_password.arn
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

resource "aws_ecs_service" "api" {
    name            = "takao-case2-1-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.api.arn
    desired_count   = 2
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
        security_groups  = [aws_security_group.ecs_sg.id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.ecs.arn
        container_name   = "api"
        container_port   = 3000
    }

    depends_on = [aws_lb_listener.http]
}
