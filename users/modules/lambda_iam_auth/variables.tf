variable "function_name" {
  type = string
}

variable "lambda_runtime" {
  default = "python3.10"
}
variable "lambda_timeout" {
  default = "100"
}

variable "lambda_memory" {
  default = "128"
}

variable "cognito_user_pool" {
  description = "Cognito user pool"
  type        = string
}

variable "user_pool_client" {
  description = "Cognito user pool client"
  type        = string
}

variable "user_pool_admin_group_name" {
  description = "Cognito user pool admin group name"
  type        = string
}

variable "role_name" {
  description = "IAM role name"
  type        = string
}

variable "role_policy" {
  type = string
}

variable "auth_policy_attachment" {
  type = string
}
