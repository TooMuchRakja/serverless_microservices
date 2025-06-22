# MODULE 4 - ASYNCHRONOUS PATTERN WITH EVENT BRIDGE AND SQS - BULDING USERS SERVICE WITH ADDRESSES AND FAVOURITES 

module "user_profile_dynamodb" {
  source = "./modules/user_profile_dynamodb"
}

module "user_profile_event_bridge_bus" {
  source = "./modules/user_profile_event_bridge_bus"
  region = var.region
  stack_name = var.stack_name
  add_address_function_arn =  module.user_profile_lambdas.add_address_function_arn
  edit_address_function_arn  = module.user_profile_lambdas.edit_address_function_arn
  delete_address_function_arn =  module.user_profile_lambdas.delete_address_function_arn
  list_address_function_arn = module.user_profile_lambdas.list_address_function_arn
  add_address_function_name = module.user_profile_lambdas.add_address_function_name
  edit_address_function_name = module.user_profile_lambdas.edit_address_function_name
  delete_address_function_name = module.user_profile_lambdas.delete_address_function_name
  list_address_function_name = module.user_profile_lambdas.list_address_function_name
}


module "user_profile_lambdas" {
  source = "./modules/user_profile_lambdas"
  region = var.region
  stack_name = var.stack_name
  address_table_name = module.user_profile_dynamodb.address_table_name
  add_address_role_arn = module.user_profile_lambda_iam.add_address_role_arn
  edit_address_role_arn = module.user_profile_lambda_iam.edit_address_role_arn
  delete_address_role_arn = module.user_profile_lambda_iam.delete_address_role_arn
  list_address_role_arn = module.user_profile_lambda_iam.list_address_role_arn
}

module "user_profile_lambda_iam" {
  source = "./modules/user_profile_lambda_iam"
  region = var.region
  add_address_function_name = module.user_profile_lambdas.add_address_function_name
  edit_address_function_name = module.user_profile_lambdas.edit_address_function_name
  delete_address_function_name = module.user_profile_lambdas.delete_address_function_name
  list_address_function_name = module.user_profile_lambdas.list_address_function_name
  address_table_name = module.user_profile_dynamodb.address_table_name
  address_api_source_arn = module.user_profile_api.address_api_source_arn
}

module "user_profile_api"  {
  source = "./modules/user_profile_api"
  region = var.region
  address_api_access_logs_arn = var.address_api_access_logs_arn
  cognito_user_pool_id = var.cognito_user_pool_id
  add_address_function_arn =  module.user_profile_lambdas.add_address_function_arn
  edit_address_function_arn  = module.user_profile_lambdas.edit_address_function_arn
  delete_address_function_arn =  module.user_profile_lambdas.delete_address_function_arn
  list_address_function_arn = module.user_profile_lambdas.list_address_function_arn
  aws_api_gateway_account_settings = var.aws_api_gateway_account_settings
  address_bus_name = module.user_profile_event_bridge_bus.address_bus_name
}

