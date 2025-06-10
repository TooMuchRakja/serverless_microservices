output "orders_api_endpoint_url" {
  value = aws_api_gateway_stage.rest_api.invoke_url
}

output "orders_api_source_arn" {
  value = aws_api_gateway_rest_api.orders_api.execution_arn
  description = "The source arn for the api gateway permissions policy"
}

output "orders_api_stage_name" {
  value = aws_api_gateway_stage.orders_stage.stage_name
}
