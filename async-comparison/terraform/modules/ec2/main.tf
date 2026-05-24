data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "defaultForAz"
    values = ["true"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2" {
  name   = "${var.project}-ec2-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = var.instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    yum install -y python3-pip
    pip3 install boto3
    cat > /home/ec2-user/worker.py << 'PYEOF'
${file("${path.module}/../../../ec2/worker.py")}
PYEOF
    cat > /etc/systemd/system/worker.service << 'SVCEOF'
[Unit]
After=network.target
[Service]
User=ec2-user
Environment=SQS_QUEUE_URL=${var.sqs_queue_url}
Environment=SLEEP_SECONDS=${var.sleep_seconds}
Environment=AWS_REGION=${var.aws_region}
ExecStart=/usr/bin/python3 /home/ec2-user/worker.py
Restart=always
[Install]
WantedBy=multi-user.target
SVCEOF
    systemctl enable worker
    systemctl start worker
  EOF

  tags = { Name = "${var.project}-ec2-worker" }
}
