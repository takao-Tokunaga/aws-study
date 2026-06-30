output "aws_lambda_function_arn" { value = aws_lambda_function.items.arn}

output "lambda_invoke_arn" {
    value = aws_lambda_function.items.invoke_arn
}