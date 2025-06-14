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

variable "orders_dynamodb_table_name" {
  type    = string
}

variable "idempotence_dynamodb_table_name" {
  type    = string
}

variable "add_order_function_role_arn" {
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

variable "python_version" {
  type    = string
  default = "python310"
}

variable "region" {
  type    = string
}

variable "powertools_service_name" {
  type    = string
  default = "orders"
}

variable "powertools_namespace" {
  type    = string
  default = "serverless_workshop"
}