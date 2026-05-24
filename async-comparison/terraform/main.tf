module "sqs" {
  source  = "./modules/sqs"
  project = var.project
}

module "cloudwatch" {
  source     = "./modules/cloudwatch"
  project    = var.project
  aws_region = var.aws_region
}

module "iam" {
  source  = "./modules/iam"
  project = var.project
}

module "ec2" {
  source                = "./modules/ec2"
  project               = var.project
  aws_region            = var.aws_region
  sqs_queue_url         = module.sqs.ec2_queue_url
  sleep_seconds         = var.sleep_seconds
  instance_profile_name = module.iam.ec2_instance_profile_name
}

module "lambda" {
  source          = "./modules/lambda"
  project         = var.project
  aws_region      = var.aws_region
  sqs_queue_arn   = module.sqs.lambda_queue_arn
  sleep_seconds   = var.sleep_seconds
  lambda_role_arn = module.iam.lambda_role_arn
}

module "ecs" {
  source                 = "./modules/ecs"
  project                = var.project
  aws_region             = var.aws_region
  sqs_queue_url          = module.sqs.ecs_queue_url
  sleep_seconds          = var.sleep_seconds
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
}
