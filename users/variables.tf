variable "region" {
  default = "eu-central-1"
}

variable "stack_name" {
  default = "serverless-workshop"
}

variable "sns_email" {
  default = "szymekp1994@gmail.com"
}

variable "users_api_access_logs" {
  type    = string
}

variable "global_api_logging_role_arn" {
  type = string
}

variable "aws_api_gateway_account_settings" {
  type = any
}