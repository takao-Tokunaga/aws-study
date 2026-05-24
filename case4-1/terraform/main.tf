module "vpc" {
  source             = "./modules/vpc"
  project            = var.project
  availability_zones = var.availability_zones
}

module "security_groups" {
  source  = "./modules/security_groups"
  project = var.project
  vpc_id  = module.vpc.vpc_id
}

module "ecr" {
  source  = "./modules/ecr"
  project = var.project
}

module "iam" {
  source  = "./modules/iam"
  project = var.project
}

module "rds" {
  source          = "./modules/rds"
  project         = var.project
  db_subnet_ids   = module.vpc.db_subnet_ids
  rds_sg_id       = module.security_groups.rds_sg_id
  db_password     = var.db_password
}

module "bastion" {
  source           = "./modules/bastion"
  project          = var.project
  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_sg_id    = module.security_groups.bastion_sg_id
  key_name         = var.key_name
}

module "alb" {
  source            = "./modules/alb"
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
}

module "ecs" {
  source                  = "./modules/ecs"
  project                 = var.project
  aws_region              = var.aws_region
  private_subnet_ids      = module.vpc.private_subnet_ids
  api_sg_id               = module.security_groups.api_sg_id
  api_target_group_arn    = module.alb.api_target_group_arn
  ecs_execution_role_arn  = module.iam.ecs_execution_role_arn
  api_task_role_arn       = module.iam.api_task_role_arn
  api_image               = var.api_image
  db_host                 = module.rds.db_endpoint
  db_name                 = module.rds.db_name
  db_username             = module.rds.db_username
  db_password             = var.db_password
  project_param_prefix    = var.project
}

module "cloudfront" {
  source      = "./modules/cloudfront"
  project     = var.project
  alb_dns     = module.alb.alb_dns_name
}

module "cloudwatch" {
  source             = "./modules/cloudwatch"
  project            = var.project
  aws_region         = var.aws_region
  ecs_cluster_name   = module.ecs.cluster_name
  ecs_service_name   = module.ecs.service_name
  slack_webhook_url  = var.slack_webhook_url
  lambda_role_arn    = module.iam.lambda_role_arn
}

module "github_actions_iam" {
  source      = "./modules/github_actions_iam"
  project     = var.project
  aws_region  = var.aws_region
  ecr_repo_arn = module.ecr.repository_arn
}
