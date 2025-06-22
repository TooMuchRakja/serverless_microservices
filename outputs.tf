output "users-api-endpoint" {
    value = module.users.users-api-endpoint
}

output "users_lambda_function_name" {
    value = module.users.users_lambda_function_name
}

output "UsersTable" {
    value = module.users.UsersTable
}

output "UserPool" {
    value = module.users.UserPool
}

output "UserPoolClient" {
    value = module.users.UserPoolClient
}

output "UserPoolAdminGroupName" {
    value = module.users.UserPoolAdminGroupName
}

output "cognito_login_url" {
    value = module.users.cognito_login_url
}

output "cognito_auth_command" {
    value = module.users.cognito_auth_command
}
output "auth_lambda_function_name" {
    value = module.users.auth_lambda_function_name
}

output "users_cloudwatch_dashboardURL" {
    value = module.users.users_cloudwatch_dashboardURL
}

output "orders_dynamodb_table_name" {
    value = module.orders.orders_dynamodb_table_name
}

output "orders_api_endpoint_url" {
    value = module.orders.orders_api_endpoint_url
}

output "Address_Table" {
    value = module.user_profile_service.address_table_name
}

output "address_api_endpoint_url" {
    value = module.user_profile_service.address_api_endpoint_url
}
