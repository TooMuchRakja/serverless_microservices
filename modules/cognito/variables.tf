variable "cognito_user_pool_name" {
  type = string
}

variable "cognito_user_pool_client_name" {
  type = string
}

variable "region" {
  type = string
}

variable "user_pool_admin_group_name" {
  description = "Cognito user pool admin group name"
  type        = string
}

variable "cognito_user_pool_domain" {
  type = string
}