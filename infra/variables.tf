variable "project_suffix" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{6,12}$", var.project_suffix))
    error_message = "Usa de 6 a 12 letras minúsculas o números; el sufijo debe ser único."
  }
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "sql_admin" {
  type    = string
  default = "bnpadmin"
}
variable "sql_password" {
  type      = string
  sensitive = true
}
