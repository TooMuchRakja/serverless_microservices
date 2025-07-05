resource "aws_cloudwatch_event_bus" "pooling_bus" {
    name = "${var.stack_name}-pooling-bus"

    tags = {
        StackName = "${var.stack_name}"
        Environment = "${var.environment}"
        Service     = "PoolingService"
    } 
}

# uprawnienia dla eventów do uruchamiania lambdy 
resource "aws_lambda_permission" "allow_invoke_pooling_function" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.update_pooling_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pooling_status_updated.arn 
}

# wskzanie po jakich nagłówkach ma być uruchamiana
resource "aws_cloudwatch_event_rule" "pooling_status_updated" {
  name           = "${var.stack_name}_pooling_restaurant"
  event_bus_name = aws_cloudwatch_event_bus.pooling_bus.name
  event_pattern = jsonencode({
    "source": ["restaurant"],
    "detail-type": ["order.updated"]
  })
}
# target czyli wskazanie która reguła ma być uruchamiana którą funkcją 
resource "aws_cloudwatch_event_target" "invoke_update_pooling_status" {
  rule           = aws_cloudwatch_event_rule.pooling_status_updated.name
  event_bus_name = aws_cloudwatch_event_bus.pooling_bus.name
  arn            = var.update_pooling_function_arn
  target_id      = "PoolUpdateHandler" # unique name, doesnt corealte with lambda handler
}
