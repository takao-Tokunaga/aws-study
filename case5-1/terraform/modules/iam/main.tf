data "aws_iam_policy_document" "lambda_assume" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "lambda" {
    name = "${var.project}-lambda-role"
    assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
    role       = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets" {
    name = "${var.project}-lambda-secrets"
    role = aws_iam_role.lambda.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = ["dynamodb:Scan", "dynamodb:GetItem"]
            Resource = var.table_arn
        }]
    })
}