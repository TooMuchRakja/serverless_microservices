output "users_api_access_logs_arn" {
    value = aws_cloudwatch_log_group.users_api_access_logs.arn
}

output "orders_api_access_logs_arn" {
    value = aws_cloudwatch_log_group.orders_api_access_logs.arn
}

output "global_api_logging_role_arn" {
    value = aws_iam_role.api_logging_role.arn
}

output "aws_api_gateway_account_settings" {
  value = aws_api_gateway_account.settings
}

output "address_api_access_logs_arn" {
  value = aws_cloudwatch_log_group.address_api_access_logs.arn
}

output "pooling_api_access_logs_arn" {
  value = aws_cloudwatch_log_group.pooling_api_access_logs.arn
}
