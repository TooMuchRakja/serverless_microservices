module "pooling_event_bus" {
    source = "./modules/pooling_event_bus"
    cognito_user_pool_id = var.cognito_user_pool_id
    orders_dynamodb_table_name = var.orders_dynamodb_table_name
    update_pooling_function_name = var.update_pooling_function_name
    stack_name = var.stack_name
    environment = var.environment
    update_pooling_function_arn  = module.pooling_lambda.update_pooling_function_arn
}

module "pooling_lambda" {
    source = "./modules/pooling_lambda"
    update_pooling_function_name = var.update_pooling_function_name
    orders_dynamodb_table_name = var.orders_dynamodb_table_name
}