output "orders_dynamodb_table_name" {
    value = aws_dynamodb_table.orders_table.name
}

output "idempotence_dynamodb_table_name" {
    value = aws_dynamodb_table.idempotence_table.name
}