variable "project"              { type = string }
variable "aws_region"           { type = string }
variable "private_subnet_id"    { type = string }
variable "api_sg_id"            { type = string }
variable "instance_profile_name" { type = string }
variable "api_target_group_arn" { type = string }
variable "log_group_name"       { type = string }

variable "db_host"     { type = string }
variable "db_name"     { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
