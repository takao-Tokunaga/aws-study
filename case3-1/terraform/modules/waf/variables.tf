variable "project"     { type = string }
variable "environment" { type = string }
variable "maintenance_mode" {
  type    = bool
  default = false
}
variable "maintenance_allowed_cidrs" {
  type    = list(string)
  default = []
}
