output "cloudfront_domain" {
    value = "https://${aws_cloudfront_distribution.cf.domain_name}"
}

output "alb_dns" {
    value = aws_lb.alb.dns_name
}

output "ecr_repository_url" {
    value = aws_ecr_repository.api.repository_url
}

output "rds_endpoint" {
    value     = aws_db_instance.main.address
    sensitive = true
}

output "bastion_instance_id" {
    value       = aws_instance.bastion.id
    description = "SSM接続: aws ssm start-session --target <この値>"
}
