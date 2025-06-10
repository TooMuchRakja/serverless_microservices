output "orders_dynamodb_table_name" {
    value = aws_dynamodb_table.orders_table.name
}