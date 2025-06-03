output "api-endpoint" {
  value = aws_api_gateway_stage.rest_api.invoke_url
}

output "api_name" {
  value = var.api_name
}