resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Name = "${var.project}-cluster" }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

# ─── IAM ──────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_ssm" {
  name = "${var.project}-ecs-execution-ssm"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameters", "ssm:GetParameter"]
      Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project}/*"
    }]
  })
}

resource "aws_iam_role" "api_task" {
  name               = "${var.project}-api-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# API タスクに S3 + KMS アクセス権限
resource "aws_iam_role_policy" "api_s3" {
  name = "${var.project}-api-s3-policy"
  role = aws_iam_role.api_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

resource "aws_iam_role" "frontend_task" {
  name               = "${var.project}-frontend-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role" "worker_task" {
  name               = "${var.project}-worker-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "${var.project}-worker-policy"
  role = aws_iam_role.worker_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = var.sqs_queue_arn
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject"]
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
      },
      {
        Effect = "Allow"
        Action = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource = "*"
      }
    ]
  })
}

# ─── CloudWatch Logs ──────────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project}/api"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.project}/frontend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.project}/worker"
  retention_in_days = 30
}

# ─── API Task Definition ──────────────────────────────────────────────────────
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.api_task.arn

  container_definitions = jsonencode([{
    name      = "api"
    image     = var.api_image
    essential = true

    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV",          value = "production" },
      { name = "PORT",              value = "3000" },
      { name = "DB_HOST",           value = var.db_host },
      { name = "DB_PORT",           value = "5432" },
      { name = "DB_NAME",           value = var.db_name },
      { name = "DB_USERNAME",       value = var.db_username },
      { name = "S3_BUCKET_NAME",    value = var.s3_bucket_name },
      { name = "S3_BUCKET_REGION",  value = var.s3_bucket_region },
      { name = "CLOUDFRONT_DOMAIN",       value = var.cloudfront_domain },
      { name = "CLOUDFRONT_KEY_PAIR_ID",  value = var.cloudfront_key_pair_id },
      { name = "AWS_REGION",              value = var.aws_region },
      { name = "SQS_QUEUE_URL",           value = var.sqs_queue_url }
    ]

    secrets = [
      { name = "DB_PASSWORD",             valueFrom = aws_ssm_parameter.db_password.arn },
      { name = "CLOUDFRONT_PRIVATE_KEY",  valueFrom = aws_ssm_parameter.cloudfront_private_key.arn }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "api"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])
}

# ─── Frontend Task Definition ─────────────────────────────────────────────────
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.frontend_task.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.frontend_image
    essential = true

    portMappings = [{
      containerPort = 3001
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV",        value = "production" },
      { name = "PORT",            value = "3001" },
      { name = "NEXT_PUBLIC_API_URL", value = "https://${var.cloudfront_domain}/api" },
      { name = "API_INTERNAL_URL",    value = "http://${var.internal_alb_dns}/api" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "frontend"
      }
    }
  }])
}

# ─── SSM Parameters ──────────────────────────────────────────────────────────
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project}/db/password"
  type  = "SecureString"
  value = var.db_password

  tags = { Name = "${var.project}-db-password" }
}

resource "aws_ssm_parameter" "cloudfront_private_key" {
  name  = "/${var.project}/cloudfront/private-key"
  type  = "SecureString"
  value = var.cloudfront_private_key

  tags = { Name = "${var.project}-cloudfront-private-key" }
}

# ─── ECS Services ─────────────────────────────────────────────────────────────
resource "aws_ecs_service" "api" {
  name            = "${var.project}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.api_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.api_target_group_arn
    container_name   = "api"
    container_port   = 3000
  }

  # Internal ALB にも登録
  load_balancer {
    target_group_arn = var.api_internal_tg_arn
    container_name   = "api"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = { Name = "${var.project}-api-service" }
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.project}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.frontend_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 3001
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = { Name = "${var.project}-frontend-service" }
}

# ─── Worker Task Definition ───────────────────────────────────────────────────
resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.project}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.worker_task.arn

  container_definitions = jsonencode([{
    name      = "worker"
    image     = var.worker_image
    essential = true

    environment = [
      { name = "AWS_REGION",     value = var.aws_region },
      { name = "SQS_QUEUE_URL",  value = var.sqs_queue_url },
      { name = "S3_BUCKET_NAME", value = var.s3_bucket_name },
      { name = "DB_HOST",        value = var.db_host },
      { name = "DB_PORT",        value = "5432" },
      { name = "DB_NAME",        value = var.db_name },
      { name = "DB_USERNAME",    value = var.db_username }
    ]

    secrets = [
      { name = "DB_PASSWORD", valueFrom = aws_ssm_parameter.db_password.arn }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.worker.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "worker"
      }
    }
  }])
}

resource "aws_ecs_service" "worker" {
  name            = "${var.project}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.worker_sg_id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = { Name = "${var.project}-worker-service" }
}
