variable "project"               { type = string }
variable "environment"           { type = string }
variable "vpc_id"                { type = string }
variable "private_subnet_ids"    { type = list(string) }
variable "api_sg_id"             { type = string }
variable "frontend_sg_id"        { type = string }
variable "api_target_group_arn"  { type = string }
variable "frontend_target_group_arn" { type = string }
variable "api_internal_tg_arn"   { type = string }
variable "api_ecr_url"           { type = string }
variable "frontend_ecr_url"      { type = string }
variable "api_image"             { type = string }
variable "frontend_image"        { type = string }
variable "db_host"               { type = string }
variable "db_name"               { type = string }
variable "db_username"           { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "s3_bucket_name"  { type = string }
variable "s3_bucket_region" { type = string }
variable "cloudfront_domain" { type = string }
variable "cloudfront_key_pair_id" {
  type    = string
  default = ""
}
variable "cloudfront_private_key" {
  type      = string
  sensitive = true
  default   = "placeholder"
}
variable "internal_alb_dns" { type = string }
variable "aws_region"       { type = string }
