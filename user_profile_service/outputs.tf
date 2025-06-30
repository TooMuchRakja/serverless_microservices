output "address_table_name" {
    value = module.user_profile_dynamodb.address_table_name
}

output "address_api_endpoint_url" {
    value = module.user_profile_api.address_api_endpoint_url
}

output "favourites_table_name" {
    value = module.favourites_dynamodb.favourites_dynamodb_table_name
}