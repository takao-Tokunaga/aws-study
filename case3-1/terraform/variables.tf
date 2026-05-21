variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "takao-case3-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-1c", "ap-northeast-1d"]
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "taskdb"
}

variable "bastion_key_name" {
  description = "EC2 key pair name for bastion host"
  type        = string
}

variable "bastion_allowed_cidr" {
  description = "CIDR allowed to SSH into bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "maintenance_mode" {
  description = "Enable WAF maintenance mode (blocks all traffic except allowed IPs)"
  type        = bool
  default     = false
}

variable "maintenance_allowed_cidrs" {
  description = "CIDR blocks allowed during maintenance mode"
  type        = list(string)
  default     = []
}

variable "api_image" {
  description = "API Docker image URI (set after first ECR push)"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "frontend_image" {
  description = "Frontend Docker image URI (set after first ECR push)"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "cloudfront_public_key_pem" {
  description = "CloudFront public key PEM for signed URLs (openssl rsa -pubout)"
  type        = string
  default     = ""
}

variable "cloudfront_private_key_pem" {
  description = "CloudFront private key PEM for signed URLs (SSM SecureString に保存)"
  type        = string
  sensitive   = true
  default     = "placeholder"
}


variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}

variable "worker_image" {
  description = "Worker Docker image URI"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}
