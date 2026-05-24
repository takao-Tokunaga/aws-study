variable "project"       { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "rds_sg_id"     { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_name" {
  type    = string
  default = "taskdb"
}
variable "db_username" {
  type    = string
  default = "postgres"
}
