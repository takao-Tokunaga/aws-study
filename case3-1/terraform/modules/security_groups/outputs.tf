output "alb_sg_id"          { value = aws_security_group.alb.id }
output "internal_alb_sg_id" { value = aws_security_group.internal_alb.id }
output "api_ecs_sg_id"      { value = aws_security_group.api_ecs.id }
output "frontend_ecs_sg_id" { value = aws_security_group.frontend_ecs.id }
output "rds_sg_id"          { value = aws_security_group.rds.id }
output "bastion_sg_id"      { value = aws_security_group.bastion.id }
