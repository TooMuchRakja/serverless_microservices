resource "aws_lambda_permission" "list_order_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayListOrders"
  action        = "lambda:InvokeFunction"
  function_name = var.list_order_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.orders_api_source_arn}/prod/GET/orders"
}

resource "aws_lambda_permission" "add_order_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayAddOrder"
  action        = "lambda:InvokeFunction"
  function_name = var.add_order_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.orders_api_source_arn}/prod/POST/orders"
}

resource "aws_lambda_permission" "get_order_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayGetOrder"
  action        = "lambda:InvokeFunction"
  function_name = var.get_order_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.orders_api_source_arn}/prod/GET/orders/*"
}

resource "aws_lambda_permission" "edit_order_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayEditOrder"
  action        = "lambda:InvokeFunction"
  function_name = var.edit_order_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.orders_api_source_arn}/prod/PUT/orders/*"
}

resource "aws_lambda_permission" "delete_order_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayDeleteOrder"
  action        = "lambda:InvokeFunction"
  function_name = var.delete_order_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.orders_api_source_arn}/prod/DELETE/orders/*"
}

