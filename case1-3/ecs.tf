// ECSクラスター
resource "aws_ecs_cluster" "main" {
    name = "takao-case3-cluster"
}

// CloudWatch Logsグループ
resource "aws_cloudwatch_log_group" "ecs" {
    name              = "/ecs/takao-case3-wordpress"
    retention_in_days = 7
}

// タスク定義
resource "aws_ecs_task_definition" "wordpress" {
    family                   = "takao-case3-wordpress"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "ARM64"
    }

    volume {
        name = "wordpress-data"

        efs_volume_configuration {
            file_system_id = aws_efs_file_system.wordpress.id
            root_directory = "/"
        }
    }

    container_definitions = jsonencode([{
        name  = "wordpress"
        image = "${aws_ecr_repository.wordpress.repository_url}:latest"
        portMappings = [{
            containerPort = 80
            protocol      = "tcp"
        }]
        mountPoints = [{
            sourceVolume  = "wordpress-data"
            containerPath = "/var/www/html"
            readOnly      = false
        }]
        environment = [
            { name = "WORDPRESS_DB_HOST",    value = aws_db_instance.wordpress.address },
            { name = "WORDPRESS_DB_USER",    value = "wpuser" },
            { name = "WORDPRESS_DB_NAME",    value = "wordpress" }
        ]
        secrets = [{
            name      = "WORDPRESS_DB_PASSWORD"
            valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
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

// ECSサービス
resource "aws_ecs_service" "wordpress" {
    name            = "takao-case3-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.wordpress.arn
    desired_count   = 2
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
        security_groups  = [aws_security_group.ecs_sg.id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.ecs.arn
        container_name   = "wordpress"
        container_port   = 80
    }
}
