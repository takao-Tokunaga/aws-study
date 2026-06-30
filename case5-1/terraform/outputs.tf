output "api_url" {
    value = module.api_gateway.api_url
}

output "user_pool_id" {
    value = module.cognito.cognito_user_pool_id
}

output "client_id" {
    value = module.cognito.cognito_user_pool_client_id
}