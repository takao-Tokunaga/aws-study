output "external_alb_arn"          { value = aws_lb.external.arn }
output "external_alb_dns_name"     { value = aws_lb.external.dns_name }
output "internal_alb_dns_name"     { value = aws_lb.internal.dns_name }
output "api_target_group_arn"      { value = aws_lb_target_group.api.arn }
output "frontend_target_group_arn" { value = aws_lb_target_group.frontend.arn }
output "api_internal_tg_arn"       { value = aws_lb_target_group.api_internal.arn }
