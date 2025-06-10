variable "region" {
  type = string
}

variable "add_order_function_arn" {
  type = string
}

variable "edit_order_function_arn" {
  type = string
}

variable "delete_order_function_arn" {
  type = string
}

variable "get_order_function_arn" {
  type = string
}

variable "list_order_function_arn" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "global_api_logging_role_arn" {
  type = string
}

variable "orders_api_access_logs" {
  type = string
}

variable "aws_api_gateway_account_settings" {
  type = any
}



