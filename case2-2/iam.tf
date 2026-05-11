# ECS Task Execution Role (ECRプル、CloudWatch Logsへの書き込み)
resource "aws_iam_role" "ecs_task_execution" {
    name = "case2-2-ecs-task-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
    role       = aws_iam_role.ecs_task_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (コンテナが実行時に使うロール)
resource "aws_iam_role" "ecs_task" {
    name = "case2-2-ecs-task-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy" "ecs_task_secrets" {
    name = "case2-2-ecs-task-secrets-policy"
    role = aws_iam_role.ecs_task.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = "secretsmanager:GetSecretValue"
            Resource = aws_secretsmanager_secret.slack_webhook.arn
        }]
    })
}

# Step Functions execution role
resource "aws_iam_role" "sfn_exec" {
    name = "case2-2-sfn-exec-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "states.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy" "sfn_ecs" {
    name = "case2-2-sfn-ecs-policy"
    role = aws_iam_role.sfn_exec.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Action   = "ecs:RunTask"
                Resource = aws_ecs_task_definition.notify_slack.arn
            },
            {
                Effect   = "Allow"
                Action   = ["ecs:StopTask", "ecs:DescribeTasks"]
                Resource = "*"
            },
            {
                # .sync統合でStep FunctionsがEventBridgeルールを作成するために必要
                Effect   = "Allow"
                Action   = ["events:PutTargets", "events:PutRule", "events:DescribeRule"]
                Resource = "arn:aws:events:ap-northeast-1:*:rule/StepFunctionsGetEventsForECSTaskRule"
            },
            {
                Effect   = "Allow"
                Action   = "iam:PassRole"
                Resource = [
                    aws_iam_role.ecs_task_execution.arn,
                    aws_iam_role.ecs_task.arn,
                ]
            }
        ]
    })
}

# EventBridge Scheduler role
resource "aws_iam_role" "scheduler_exec" {
    name = "case2-2-scheduler-exec-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "scheduler.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy" "scheduler_start_sfn" {
    name = "case2-2-scheduler-start-sfn-policy"
    role = aws_iam_role.scheduler_exec.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = "states:StartExecution"
            Resource = aws_sfn_state_machine.notify.arn
        }]
    })
}
