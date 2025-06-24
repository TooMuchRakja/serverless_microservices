output "address_api_source_arn" {
  value = aws_api_gateway_rest_api.address_api.execution_arn
}

output "address_api_endpoint_url" {
  value = aws_api_gateway_stage.address_stage.invoke_url
}

output "address_api_stage_name" {
  value = aws_api_gateway_stage.address_stage.stage_name
}

