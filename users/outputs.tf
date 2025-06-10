output "users-api-endpoint" {
    value = module.api-gateway.api-endpoint
}

output "users_lambda_function_name" {
    value = module.lambda.lambda_function_name
}

output "UsersTable" {
    value = module.dynamodb.dynamodb_table_name
}

output "UserPool" {
    value = module.cognito.UserPool
}

output "UserPoolClient" {
    value = module.cognito.UserPoolClient
}

output "UserPoolAdminGroupName" {
    value = module.cognito.UserPoolAdminGroupName
}

output "cognito_login_url" {
    value = module.cognito.CognitoLoginURL
}

output "cognito_auth_command" {
    value = module.cognito.CognitoAuthCommand
}
output "auth_lambda_function_name" {
    value = module.lambda_authorizer.lambda_auth_name
}

output "users_cloudwatch_dashboardURL" {
    value = module.cloudwatch_dashboard.dashboard_url
}

