variable "project"               { type = string }
variable "environment"           { type = string }
variable "alb_dns_name"          { type = string }
variable "s3_bucket_id"          { type = string }
variable "s3_bucket_domain_name" { type = string }
variable "waf_acl_arn"           { type = string }
variable "cloudfront_public_key_pem" {
  type    = string
  default = ""
}
