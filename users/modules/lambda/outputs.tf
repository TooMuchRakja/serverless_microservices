output "lambda_function_name" {
  value = aws_lambda_function.userfunctions_lambda.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.userfunctions_lambda.arn
}

output "UserPool" {
  value = module.cognito.UserPool
}