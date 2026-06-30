data "archive_file" "lambda" {
    type = "zip"
    source_file = "${path.root}/../src/index.js"
    output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "items"{
    function_name    = "${var.project}-lambda-function"
    filename         = data.archive_file.lambda.output_path
    source_code_hash = data.archive_file.lambda.output_base64sha256
    runtime          = "nodejs22.x"
    handler          = "index.handler"
    role             = var.lambda_role_arn
    environment {
        variables = {
            TABLE_NAME = var.table_name
        }
    }
}  

resource "aws_lambda_permission" "api_gateway" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.items.function_name
    principal     = "apigateway.amazonaws.com"
}