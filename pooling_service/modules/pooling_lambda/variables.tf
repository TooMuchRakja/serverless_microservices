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

variable "update_pooling_function_name" {
  type = string
}

variable "region" {
    type = string
}

variable "environment" {
  type = string
}

variable "stack_name" {
    type = string
}

variable "orders_dynamodb_table_name" {
    type = string
}
