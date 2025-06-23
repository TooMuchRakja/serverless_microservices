variable "region" {
    type = string
}

variable "stack_name" {
    type = string
}

variable "cognito_user_pool_id" {
    type = string
}
    
variable "global_api_logging_role_arn" {
    type = string
}

variable "aws_api_gateway_account_settings" {
    type = string
}

variable "address_api_access_logs_arn" {
    type = string
}

variable "add_address_function_name" {
    type = string
    default = "serverless_ws_add_address_function"
}

variable "edit_address_function_name" {
    type = string
    default = "serverless_ws_edit_address_function"
}

variable "delete_address_function_name" {
    type = string
    default = "serverless_ws_delete_address_function"
}

variable "list_address_function_name" {
    type = string
    default = "serverless_ws_list_address_function"
}

