variable "region" {
  type = string
}

variable "address_api_access_logs_arn" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "add_address_function_arn" {
  type = string
}

variable "edit_address_function_arn" {
  type = string
}

variable "delete_address_function_arn" {
  type = string
}

variable "list_address_function_arn" {
  type = string
}

variable "global_api_logging_role" {
  type = string
}

variable "aws_api_gateway_account_settings" {
  type = any
}

variable "address_bus_name" {
  type = string
}


