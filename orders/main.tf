# comment placeholder
module "orders_apigateway" {
  source     = "./modules/orders_apigateway"
  region     = var.region
  add_order_function_arn = module.orders_lambda.add_order_lambda_arn
  edit_order_function_arn = module.orders_lambda.edit_order_lambda_arn
  delete_order_function_arn = module.orders_lambda.delete_order_lambda_arn
  get_order_function_arn = module.orders_lambda.get_order_lambda_arn
  list_order_function_arn = module.orders_lambda.list_order_lambda_arn
  cognito_user_pool_id = var.cognito_user_pool_id
  global_api_logging_role_arn = var.global_api_logging_role_arn
  orders_api_access_logs = var.orders_api_access_logs
  aws_api_gateway_account_settings = var.aws_api_gateway_account_settings
}

module "orders_dynamodb" {
  source     = "./modules/orders_dynamodb"
  stack_name = var.stack_name
}

module "orders_lambda" {
  source                   = "./modules/orders_lambda"
  region                  = var.region
  add_order_function_name = var.add_order_function_name
  edit_order_function_name = var.edit_order_function_name
  delete_order_function_name = var.delete_order_function_name
  get_order_function_name = var.get_order_function_name
  list_order_function_name = var.list_order_function_name
  add_order_function_role_arn = module.orders_lambda_iam.add_order_function_role_arn
  edit_order_function_role_arn = module.orders_lambda_iam.edit_order_function_role_arn
  delete_order_function_role_arn = module.orders_lambda_iam.delete_order_function_role_arn
  get_order_function_role_arn = module.orders_lambda_iam.get_order_function_role_arn
  list_order_function_role_arn = module.orders_lambda_iam.list_order_function_role_arn
  orders_dynamodb_table_name = module.orders_dynamodb.orders_dynamodb_table_name
  idempotence_dynamodb_table_name = module.orders_dynamodb.idempotence_dynamodb_table_name

}

module "orders_lambda_iam" {
  source = "./modules/orders_lambda_iam"
  region = var.region 
  add_order_function_name = var.add_order_function_name
  edit_order_function_name = var.edit_order_function_name
  delete_order_function_name = var.delete_order_function_name
  get_order_function_name = var.get_order_function_name
  list_order_function_name = var.list_order_function_name
  orders_dynamodb_table_name = module.orders_dynamodb.orders_dynamodb_table_name
  idempotence_dynamodb_table_name = module.orders_dynamodb.idempotence_dynamodb_table_name
}

module "orders_api_iam" {
  source = "./modules/orders_api_iam"
  add_order_function_name = var.add_order_function_name
  edit_order_function_name = var.edit_order_function_name
  delete_order_function_name = var.delete_order_function_name
  get_order_function_name = var.get_order_function_name
  list_order_function_name = var.list_order_function_name
  orders_api_source_arn =  module.orders_apigateway.orders_api_source_arn
}

