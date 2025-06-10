output "lambda_auth_name" {
  value = aws_lambda_function.userfunctions_lambda_auth.function_name
}

output "auth_function_arn" {
  value = aws_lambda_function.userfunctions_lambda_auth.arn
}