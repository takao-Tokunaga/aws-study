# External ALB: CloudFront からの HTTP/HTTPS のみ許可
resource "aws_security_group" "alb" {
  name   = "${var.project}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from anywhere (CloudFront)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere (CloudFront)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-alb-sg" }
}

# Internal ALB: VPC 内からのみ許可
resource "aws_security_group" "internal_alb" {
  name   = "${var.project}-internal-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-internal-alb-sg" }
}

# API ECS: Internal ALB + External ALB からのみ許可
resource "aws_security_group" "api_ecs" {
  name   = "${var.project}-api-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "From external ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "From internal ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-api-ecs-sg" }
}

# Frontend ECS: External ALB からのみ許可
resource "aws_security_group" "frontend_ecs" {
  name   = "${var.project}-frontend-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "From external ALB"
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-frontend-ecs-sg" }
}

# RDS: ECS + Bastion からのみ許可
resource "aws_security_group" "rds" {
  name   = "${var.project}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "PostgreSQL from API ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.api_ecs.id]
  }

  ingress {
    description     = "PostgreSQL from Bastion"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-rds-sg" }
}

# Worker ECS: SQS ポーリング用（アウトバウンドのみ）
resource "aws_security_group" "worker_ecs" {
  name        = "${var.project}-worker-ecs-sg"
  description = "Worker ECS tasks"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-worker-ecs-sg" }
}

resource "aws_security_group_rule" "rds_from_worker" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.worker_ecs.id
}

# Bastion EC2
resource "aws_security_group" "bastion" {
  name   = "${var.project}-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from allowed CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-bastion-sg" }
}
