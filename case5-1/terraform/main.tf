terraform  {
    backend "s3" {
        bucket = "case5-1-tfstate-058898200941"
        key    = "case5-1/terraform.tfstate"
        region = "ap-northeast-1" 
    }
}

module "dynamodb" {
    source     = "./modules/dynamodb"
    table_name = "case5-1-table"
}

module "iam" {
    source    = "./modules/iam"
    project   = var.project
    table_arn = module.dynamodb.table_arn
}

module "lambda" {
    source          = "./modules/lambda"
    project         = var.project
    lambda_role_arn = module.iam.lambda_role_arn
    table_name      = module.dynamodb.table_name
}

module "api_gateway" {
    source                = "./modules/api_gateway"
    project               = var.project
    lambda_invoke_arn     = module.lambda.lambda_invoke_arn
    cognito_user_pool_arn = module.cognito.cognito_user_pool_arn
}

module "cognito" {
    source  = "./modules/cognito"
    project = var.project
}