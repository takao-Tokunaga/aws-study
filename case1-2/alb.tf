resource "aws_lb" "alb" {
    name                = "takao-case2-alb"
    internal            = false   // インターネット向け
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.alb_sg.id]
    subnets             = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

    tags = {
        Name = "takao-case2-alb"
    }
}

// EC2のポート80に転送する
resource "aws_lb_target_group" "tg" {
    name     = "takao-case2-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.vpc.id

    health_check {
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        interval            = 30
    }
}

// ALBのポート80に来たらターゲットグループに流す
resource "aws_lb_listener" "http" {
    load_balancer_arn  = aws_lb.alb.arn
    port               = 80
    protocol           = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}

resource "aws_lb_target_group_attachment" "ec2" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.web.id
    port             = 80
}