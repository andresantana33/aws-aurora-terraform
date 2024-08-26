#--------
# Aurora
#--------
variable "db_config" {
  type = map(any)
}

variable "Terraform" {
  type    = string
  default = "true"
}

variable "port" {
  description = "Porta BD"
  default     = "5432"
  type        = number
}

variable "username" {
  description = "Nome de usuario do banco de dados"
  default     = "postgres"
}

