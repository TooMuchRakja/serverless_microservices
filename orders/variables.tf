variable "region" {
  default = "eu-central-1"
}

variable "stack_name" {
  default = "serverless-workshop"
}

variable "sns_email" {
  default = "szymekp1994@gmail.com"
}

variable "orders_table_name" {
  type = string
}

variable "add_order_function_name" {
  type    = string
  default = "serverless-ws-add-order-function"
}

variable "edit_order_function_name" {
  type    = string
  default = "serverless-ws-edit-order-function"
}

variable "delete_order_function_name" {
  type    = string
  default = "serverless-ws-delete-order-function"
}

variable "get_order_function_name" {
  type    = string
  default = "serverless-ws-get-order-function"
}

variable "list_orders_function_name" {
  type    = string
  default = "serverless-ws-list-orders-function"
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
