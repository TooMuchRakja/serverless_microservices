variable "stack_name" {
  type = string
}

variable "lambda_runtime" {
  type    = string
  default = "python3.10"
}

variable "lambda_memory" {
  type    = number
  default = 128
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "python_version" {
  type    = string
  default = "python310"
}

variable "region" {
  type    = string
}

variable "address_table_name" {
  type = string
}

variable "add_address_role_arn" {
  type = string
}

variable "edit_address_role_arn" {
  type = string
}

variable "delete_address_role_arn" {
  type = string
}