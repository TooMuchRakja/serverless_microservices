output "favourites_dynamodb_table_name" {
    value = aws_dynamodb_table.favourites_ddbtable.name
}