data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_name

  # psql + Node.js for manual migration via bastion
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y postgresql15
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    dnf install -y nodejs git
    echo "Bastion ready."
    echo "psql: psql -h <RDS_ENDPOINT> -U postgres -d taskdb"
    echo "migration: cd /tmp && git clone https://github.com/takao-Tokunaga/aws-study && cd aws-study/case4-2/api && npm ci && npm run build && DB_HOST=<RDS_ENDPOINT> DB_PASSWORD=<PASSWORD> npm run migration:run"
  EOF

  tags = { Name = "${var.project}-bastion" }
}
