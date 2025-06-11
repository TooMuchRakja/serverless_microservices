output "add_order_lambda_arn" {
    value = aws_lambda_function.add_order_lambda.arn
}

output "edit_order_lambda_arn" {
    value = aws_lambda_function.edit_order_lambda.arn
}

output "delete_order_lambda_arn" {
    value = aws_lambda_function.delete_order_lambda.arn
}

output "get_order_lambda_arn" {
    value = aws_lambda_function.get_order_lambda.arn
}

output "list_order_lambda_arn" {
    value = aws_lambda_function.list_order_lambda.arn
}
