variable "project"                { type = string }
variable "aws_region"             { type = string }
variable "private_subnet_ids"     { type = list(string) }
variable "api_sg_id"              { type = string }
variable "api_target_group_arn"   { type = string }
variable "ecs_execution_role_arn" { type = string }
variable "api_task_role_arn"      { type = string }
variable "api_image"              { type = string }
variable "db_host"                { type = string }
variable "db_name"                { type = string }
variable "db_username"            { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "project_param_prefix"   { type = string }
