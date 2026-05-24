output "cloudfront_domain"  { value = module.cloudfront.domain_name }
output "alb_dns_name"       { value = module.alb.alb_dns_name }
output "ecr_repository_url" { value = module.ecr.repository_url }
output "rds_endpoint"       { value = module.rds.db_endpoint }
output "bastion_public_ip"  { value = module.bastion.public_ip }
