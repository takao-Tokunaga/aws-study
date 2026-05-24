output "cloudfront_domain" { value = module.cloudfront.domain_name }
output "alb_dns_name"      { value = module.alb.alb_dns_name }
output "ec2_instance_id"   { value = module.ec2.instance_id }
output "rds_endpoint"      { value = module.rds.db_endpoint }
output "bastion_public_ip" { value = module.bastion.public_ip }
output "deploy_role_arn"   { value = module.github_actions_iam.role_arn }
