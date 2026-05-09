output "cloudfront_domain" {
    value = "https://${aws_cloudfront_distribution.cf.domain_name}"
}

output "alb_dns" {
    value = aws_lb.alb.dns_name
}

output "rds_endpoint" {
    value     = aws_db_instance.wordpress.address
    sensitive = true
}

output "ecr_repository_url" {
    value = aws_ecr_repository.wordpress.repository_url
}
