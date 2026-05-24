output "instance_id"      { value = aws_instance.api.id }
output "private_ip"       { value = aws_instance.api.private_ip }
output "ssm_param_name"   { value = aws_ssm_parameter.db_password.name }
