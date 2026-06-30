resource "aws_api_gateway_rest_api" "items" {
    name  = var.project
    endpoint_configuration {
    types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_resource" "items" {
    path_part = "items"
    parent_id = aws_api_gateway_rest_api.items.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.items.id
}

resource "aws_api_gateway_method" "items" {
    rest_api_id   = aws_api_gateway_rest_api.items.id
    resource_id   = aws_api_gateway_resource.items.id
    http_method   = "GET"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "items" {
    rest_api_id             = aws_api_gateway_rest_api.items.id
    resource_id             = aws_api_gateway_resource.items.id
    http_method             = aws_api_gateway_method.items.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_method" "options" {
    rest_api_id   = aws_api_gateway_rest_api.items.id
    resource_id   = aws_api_gateway_resource.items.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
    rest_api_id             = aws_api_gateway_rest_api.items.id
    resource_id             = aws_api_gateway_resource.items.id
    http_method             = aws_api_gateway_method.options.http_method
    type                    = "MOCK"
    request_templates = {
        "application/json" = "{\"statusCode\": 200}"
    }
}

resource "aws_api_gateway_deployment" "items" {
    rest_api_id = aws_api_gateway_rest_api.items.id

    triggers = {
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.items.id,
            aws_api_gateway_method.items.id,
            aws_api_gateway_integration.items.id,
            aws_api_gateway_authorizer.cognito.id,
            aws_api_gateway_method.options.id,
            aws_api_gateway_integration.options.id,
            aws_api_gateway_integration_response.options.id,
            aws_api_gateway_gateway_response.unauthorized.id,
        ]))
    }

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        aws_api_gateway_integration.items,
        aws_api_gateway_integration_response.options,
    ]
}

resource "aws_api_gateway_stage" "items" {
    rest_api_id   = aws_api_gateway_rest_api.items.id
    deployment_id = aws_api_gateway_deployment.items.id
    stage_name    = "prod"
}

resource "aws_api_gateway_authorizer" "cognito" {
    name          = "${var.project}-authorizer"
    rest_api_id   = aws_api_gateway_rest_api.items.id
    type          = "COGNITO_USER_POOLS"
    provider_arns = [var.cognito_user_pool_arn]
}

resource "aws_api_gateway_method_response" "options" {
    rest_api_id = aws_api_gateway_rest_api.items.id
    resource_id = aws_api_gateway_resource.items.id
    http_method = aws_api_gateway_method.options.http_method
    status_code = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
    }
    depends_on = [aws_api_gateway_integration.options] 
}

resource "aws_api_gateway_integration_response" "options" {
    rest_api_id = aws_api_gateway_rest_api.items.id
    resource_id = aws_api_gateway_resource.items.id
    http_method = aws_api_gateway_method.options.http_method
    status_code = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
        "method.response.header.Access-Control-Allow-Origin"  = "'http://localhost:5173'"
    }
}

resource "aws_api_gateway_gateway_response" "unauthorized" {
    rest_api_id   = aws_api_gateway_rest_api.items.id
    response_type = "UNAUTHORIZED"
    status_code   = "401"

    response_parameters = {
        "gatewayresponse.header.Access-Control-Allow-Origin"  = "'http://localhost:5173'"
        "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    }
}