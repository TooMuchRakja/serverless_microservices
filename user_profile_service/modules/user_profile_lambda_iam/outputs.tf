output "add_address_role_arn" {
    value = aws_iam_role.add_address_function_role.arn
}

output "edit_address_role_arn"  {
    value = aws_iam_role.edit_address_function_role.arn
}

output "delete_address_role_arn" {
    value = aws_iam_role.delete_address_function_role.arn
}

output "list_address_role_arn" {
    value = aws_iam_role.list_address_function_role.arn
}