// タスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "takao-case3-ecs-execution-role"

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