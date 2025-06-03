variable "lambda_memory" {
  default = "128"
}
variable "lambda_runtime" {
  default = "python3.10"
}
variable "lambda_timeout" {
  default = "100"
}
variable "lambda_tracing_config" {
  default = "Active"
}

variable "function_name" {
  type = string
}

#dynamo_table_id - zmienna przekazana z maina, ktora jest rownoczesnie outputem z dynamo db 
variable "table_name" {
  description = "Name of DynamoDb table "
  type        = string
}

variable "lambda_role_arn" {
  type = string
}