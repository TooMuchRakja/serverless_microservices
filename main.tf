terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}

module "global_api" {
  source = "./global_api_settings"
  api_account_name = var.stack_name
}

module "users" {
  source = "./users"
  region = var.region
  stack_name = var.stack_name
  sns_email = var.sns_email
  global_api_logging_role_arn = module.global_api.api_logging_role.arn
  users_api_access_logs  = module.global_api.users_api_access_logs_arn
  aws_api_gateway_account_settings = module.global_api.aws_api_gateway_account_settings
}

module "orders" {
  source = "./orders"
  region = var.region
  stack_name = var.stack_name
  cognito_user_pool_id = module.users.UserPool
  global_api_logging_role_arn = module.global_api.api_logging_role.arn
  orders_api_access_logs = module.global_api.orders_api_access_logs_arn
  aws_api_gateway_account_settings = module.global_api.aws_api_gateway_account_settings
}