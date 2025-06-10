output "orders_dynamodb_table_name" {
  value = module.orders_dynamodb.orders_dynamodb_table_name
}

output "orders_api_endpoint_url" {
    value = module.orders_apigateway.orders_api_endpoint_url
}
