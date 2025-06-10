output "add_order_function_role_arn" {
    value = aws_iam_role.add_order_function_role.arn
} 

output "edit_order_function_role_arn" {
    value = aws_iam_role.add_order_function_role.arn
}

output "delete_order_function_role_arn" {
    value = aws_iam_role.delete_order_function_role.arn
}

output "get_order_function_role_arn" {
    value = aws_iam_role.get_order_function_role.arn
}

output "list_order_function_role_arn" {
    value = aws_iam_role.list_orders_function_role.arn
}