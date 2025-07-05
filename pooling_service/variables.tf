variable "region" {
    type = string
}

variable "stack_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "orders_dynamodb_table_name" {
    type = string
}

variable "cognito_user_pool_id" {
    type = string
}
    
variable "global_api_logging_role_arn" {
    type = string
}

variable "aws_api_gateway_account_settings" {
    type = any
}

variable "pooling_api_access_logs_arn" {
    type = string
}

variable "update_pooling_function_name" {
    default     = "update_pooling_function"
    type        = string
}