// ECSタスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "takao-case2-1-ecs-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "secrets_access" {
    name = "secrets-access"
    role = aws_iam_role.ecs_task_execution_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = ["secretsmanager:GetSecretValue"]
            Resource = [aws_secretsmanager_secret.db_password.arn]
        }]
    })
}

// 踏み台EC2ロール (SSM Session Manager)
resource "aws_iam_role" "bastion" {
    name = "takao-case2-1-bastion-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
    role       = aws_iam_role.bastion.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
    name = "takao-case2-1-bastion-profile"
    role = aws_iam_role.bastion.name
}
