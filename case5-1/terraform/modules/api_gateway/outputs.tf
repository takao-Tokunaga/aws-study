output "api_url" {
    value = aws_api_gateway_stage.items.invoke_url
}