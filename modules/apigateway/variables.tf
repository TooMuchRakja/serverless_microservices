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