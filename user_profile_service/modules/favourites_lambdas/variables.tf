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

variable "favourites_dynamodb_table_name" {
  type = string
}

variable "add_favourites_function_name" {
  type = string
}

variable "list_favourites_function_name" {
  type = string
}

variable "add_favourites_role_arn" {
  type = string
}

variable "list_favourites_role_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "stack_name" {
    type = string
}

variable "favourites_sqs_queue_arn" {
  type = string
}




