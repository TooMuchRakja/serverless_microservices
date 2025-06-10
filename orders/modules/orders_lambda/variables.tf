variable "add_order_function_name" {
  type    = string
}

variable "edit_order_function_name" {
  type    = string
}

variable "delete_order_function_name" {
  type    = string
}

variable "get_order_function_name" {
  type    = string
}

variable "list_order_function_name" {
  type    = string
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

varibale "orders_dynamodb_table_name" {
  type    = string
}

varibale "add_order_function_role_arn" {
  type    = string
}

variable "edit_order_function_role_arn" {
  type    = string
}

variable "delete_order_function_role_arn" {
  type    = string
}

variable "get_order_function_role_arn" {
  type    = string
}

variable "list_order_function_role_arn" {
  type    = string
}

