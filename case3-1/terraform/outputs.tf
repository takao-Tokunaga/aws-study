output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "api_ecr_repository_url" {
  description = "API ECR repository URL"
  value       = module.ecr.api_repository_url
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = module.ecr.frontend_repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.bastion.public_ip
}

output "s3_bucket_name" {
  description = "S3 bucket name for images"
  value       = module.s3.bucket_id
}

output "external_alb_dns" {
  description = "External ALB DNS name"
  value       = module.alb.external_alb_dns_name
}
