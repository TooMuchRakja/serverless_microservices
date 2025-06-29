output "add_favourites_function_arn" {
    value = aws_lambda_function.add_favourites_function.arn
}

output "list_favourites_function_arn" {
    value = aws_lambda_function.list_favourites_function.arn
}