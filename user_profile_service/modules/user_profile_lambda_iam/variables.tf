variable "region" {
    type = string
}

variable "add_address_function_name" {
    type = string
}

variable "edit_address_function_name" {
    type = string
}

variable "delete_address_function_name" {
    type = string
}

variable "list_address_function_name" {
    type = string
}

variable "address_table_name" {
    type = string
}

variable "address_api_source_arn" {
    type = string
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

variable "favourites_sqs_queue_name" {
  type = string
}

