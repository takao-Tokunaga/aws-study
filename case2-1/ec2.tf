// 踏み台EC2 - SSM Session Managerで接続 (SSH不要)
// 接続: aws ssm start-session --target <instance_id>
data "aws_ami" "amazon_linux_2023" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["al2023-ami-*-x86_64"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "bastion" {
    ami                         = data.aws_ami.amazon_linux_2023.id
    instance_type               = "t3.micro"
    subnet_id                   = aws_subnet.public_1a.id  // ap-northeast-1d
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
    iam_instance_profile        = aws_iam_instance_profile.bastion.name

    user_data = <<-EOF
        #!/bin/bash
        dnf install -y mariadb105
    EOF

    tags = {
        Name = "takao-case2-1-bastion"
    }
}
