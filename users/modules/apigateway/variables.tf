variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "function_arn" {
  description = "Lambda function arn"
  type        = string
}

variable "api_name" {
  description = "API Gateway name"
  type        = string
}

variable "auth_function_arn" {
  type = string
}

variable "lambda_auth_name" {
  type = string
}

variable "api_account_name" {
  description = "API account name"
  type        = string
}

variable "global_api_logging_role_arn" {
  description = "Global API logging role arn"
  type        = string
}

variable "users_api_access_logs" {
  description = "Users API access logs"
  type        = string
}

variable "aws_api_gateway_account_settings" {
  description = "API Gateway account settings"
  type        = any
}