module "vpc" {
  source             = "./modules/vpc"
  project            = var.project
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "ecr" {
  source      = "./modules/ecr"
  project     = var.project
  environment = var.environment
}

module "security_groups" {
  source      = "./modules/security_groups"
  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
}

module "alb" {
  source             = "./modules/alb"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
  internal_alb_sg_id = module.security_groups.internal_alb_sg_id
}

module "rds" {
  source            = "./modules/rds"
  project           = var.project
  environment       = var.environment
  db_subnet_ids     = module.vpc.db_subnet_ids
  rds_sg_id         = module.security_groups.rds_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
}

module "bastion" {
  source               = "./modules/bastion"
  project              = var.project
  environment          = var.environment
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  bastion_sg_id        = module.security_groups.bastion_sg_id
  key_name             = var.bastion_key_name
  allowed_cidr_blocks  = var.bastion_allowed_cidr
}

module "s3" {
  source      = "./modules/s3"
  project     = var.project
  environment = var.environment
}

module "waf" {
  source                    = "./modules/waf"
  project                   = var.project
  environment               = var.environment
  maintenance_mode          = var.maintenance_mode
  maintenance_allowed_cidrs = var.maintenance_allowed_cidrs
  providers = {
    aws = aws.us_east_1
  }
}

module "cloudfront" {
  source                   = "./modules/cloudfront"
  project                  = var.project
  environment              = var.environment
  alb_dns_name             = module.alb.external_alb_dns_name
  s3_bucket_id             = module.s3.bucket_id
  s3_bucket_domain_name    = module.s3.bucket_regional_domain_name
  waf_acl_arn              = module.waf.waf_acl_arn
  cloudfront_public_key_pem = var.cloudfront_public_key_pem
}

module "sqs" {
  source  = "./modules/sqs"
  project = var.project
}

module "ecs" {
  source                    = "./modules/ecs"
  project                   = var.project
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  api_sg_id                 = module.security_groups.api_ecs_sg_id
  frontend_sg_id            = module.security_groups.frontend_ecs_sg_id
  api_target_group_arn      = module.alb.api_target_group_arn
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  api_internal_tg_arn       = module.alb.api_internal_tg_arn
  api_ecr_url               = module.ecr.api_repository_url
  frontend_ecr_url          = module.ecr.frontend_repository_url
  api_image                 = var.api_image
  frontend_image            = var.frontend_image
  db_host                   = module.rds.db_endpoint
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  s3_bucket_name            = module.s3.bucket_id
  s3_bucket_region          = var.aws_region
  cloudfront_domain         = module.cloudfront.distribution_domain_name
  cloudfront_key_pair_id    = module.cloudfront.cloudfront_public_key_id
  cloudfront_private_key    = var.cloudfront_private_key_pem
  internal_alb_dns          = module.alb.internal_alb_dns_name
  aws_region                = var.aws_region
  worker_sg_id              = module.security_groups.worker_ecs_sg_id
  worker_image              = var.worker_image
  sqs_queue_url             = module.sqs.queue_url
  sqs_queue_arn             = module.sqs.queue_arn
}

# CloudFront の S3 アクセス許可（OAC 用）
resource "aws_s3_bucket_policy" "images" {
  bucket = module.s3.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })
}
