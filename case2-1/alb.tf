resource "aws_lb" "alb" {
    name               = "takao-case2-1-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

    tags = {
        Name = "takao-case2-1-alb"
    }
}

resource "aws_lb_target_group" "ecs" {
    name        = "takao-case2-1-tg"
    port        = 3000
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id
    target_type = "ip"

    health_check {
        path                = "/health"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 30
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.ecs.arn
    }
}
