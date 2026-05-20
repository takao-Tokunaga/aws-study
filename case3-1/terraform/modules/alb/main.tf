# ─── External ALB ────────────────────────────────────────────────────────────
resource "aws_lb" "external" {
  name               = "${var.project}-ext-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = { Name = "${var.project}-ext-alb" }
}

# API Target Group
resource "aws_lb_target_group" "api" {
  name        = "${var.project}-api-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = { Name = "${var.project}-api-tg" }
}

# Frontend Target Group
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project}-frontend-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }

  tags = { Name = "${var.project}-frontend-tg" }
}

# HTTP Listener (CloudFront からは HTTP でも可)
resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.external.arn
  port              = 80
  protocol          = "HTTP"

  # デフォルトはフロントエンドへ転送
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# /api/* → API ECS
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.external_http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# ─── Internal ALB (Frontend ECS → API ECS) ───────────────────────────────────
resource "aws_lb" "internal" {
  name               = "${var.project}-int-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.private_subnet_ids

  tags = { Name = "${var.project}-int-alb" }
}

resource "aws_lb_target_group" "api_internal" {
  name        = "${var.project}-api-int-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/api/health"
    matcher  = "200"
    interval = 30
  }

  tags = { Name = "${var.project}-api-int-tg" }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_internal.arn
  }
}
