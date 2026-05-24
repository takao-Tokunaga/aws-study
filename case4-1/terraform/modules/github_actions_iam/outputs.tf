output "role_arn" {
  description = "GitHub Actions deploy role ARN (set as AWS_DEPLOY_ROLE_ARN secret)"
  value       = aws_iam_role.deploy.arn
}
