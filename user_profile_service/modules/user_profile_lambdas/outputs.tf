
output "add_address_function_arn" {
    value = aws_lambda_function.add_address_function.arn
}

output "edit_address_function_arn" {
    value = aws_lambda_function.edit_address_function.arn
}

output "delete_address_function_arn" {
    value = aws_lambda_function.delete_address_function.arn
}

output "list_address_function_arn" {
    value = aws_lambda_function.list_address_function.arn
}
