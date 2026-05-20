variable "project"             { type = string }
variable "environment"         { type = string }
variable "public_subnet_id"    { type = string }
variable "bastion_sg_id"       { type = string }
variable "key_name"            { type = string }
variable "allowed_cidr_blocks" { type = list(string) }
