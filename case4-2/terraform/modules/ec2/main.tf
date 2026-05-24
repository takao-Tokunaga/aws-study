# ─── SSM Parameter (DB パスワード) ────────────────────────────────────────────
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project}/db/password"
  type  = "SecureString"
  value = var.db_password
  tags  = { Name = "${var.project}-db-password" }
}

# ─── Amazon Linux 2023 AMI ────────────────────────────────────────────────────
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ─── EC2 API サーバー ──────────────────────────────────────────────────────────
resource "aws_instance" "api" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.small"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.api_sg_id]
  iam_instance_profile   = var.instance_profile_name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    project        = var.project
    aws_region     = var.aws_region
    db_host        = var.db_host
    db_name        = var.db_name
    db_username    = var.db_username
    log_group_name = var.log_group_name
  })

  # user_data 変更時にインスタンスを再作成
  user_data_replace_on_change = true

  tags = { Name = "${var.project}-api" }

  depends_on = [aws_ssm_parameter.db_password]
}

# ─── ALB ターゲットグループへの登録 ───────────────────────────────────────────
resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = var.api_target_group_arn
  target_id        = aws_instance.api.id
  port             = 3000
}
