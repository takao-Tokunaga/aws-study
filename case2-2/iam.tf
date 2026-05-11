# Lambda execution role
resource "aws_iam_role" "lambda_exec" {
    name = "case2-2-lambda-exec-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "lambda.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
    role       = aws_iam_role.lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets" {
    name = "case2-2-lambda-secrets-policy"
    role = aws_iam_role.lambda_exec.id

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

resource "aws_iam_role_policy" "sfn_invoke_lambda" {
    name = "case2-2-sfn-invoke-lambda-policy"
    role = aws_iam_role.sfn_exec.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = "lambda:InvokeFunction"
            Resource = aws_lambda_function.notify_slack.arn
        }]
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
