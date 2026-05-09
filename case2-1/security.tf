// ALB: CloudFrontからのHTTPを受け付ける
resource "aws_security_group" "alb_sg" {
    name   = "takao-case2-1-alb-sg"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// ECS: ALBからのトラフィックのみ許可
resource "aws_security_group" "ecs_sg" {
    name   = "takao-case2-1-ecs-sg"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port       = 3000
        to_port         = 3000
        protocol        = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// 踏み台EC2: SSM Session Manager経由で接続するためインバウンドルール不要
resource "aws_security_group" "bastion_sg" {
    name   = "takao-case2-1-bastion-sg"
    vpc_id = aws_vpc.vpc.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// RDS: ECSと踏み台からのMySQL接続を許可
resource "aws_security_group" "rds_sg" {
    name   = "takao-case2-1-rds-sg"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.ecs_sg.id, aws_security_group.bastion_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
