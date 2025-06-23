resource "aws_cloudwatch_event_bus" "address_bus" {
    name = "${var.stack_name}-address-bus" 
}

# ADD PERMISSION TO INVOKE ANY  INDICATED LAMBDA FUNCTIONS - WE NEED THREE SEPARATE INVOKES, DOESN WORK WITH LIST OF FUNCTION NAMES 

resource "aws_lambda_permission" "allow_invoke_add_address_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.add_address_function_name 
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bus_address_added.arn
}

resource "aws_lambda_permission" "allow_invoke_edit_address_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.edit_address_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bus_address_edited.arn 
}

resource "aws_lambda_permission" "allow_invoke_delete_address_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.delete_address_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bus_address_deleted.arn 
}

# DEFINE EVENT FOR ADD  ADDRESS FUNCTION 
resource "aws_cloudwatch_event_rule" "bus_address_added" {
  name           = "${var.stack_name}_address_added"
  event_bus_name = aws_cloudwatch_event_bus.address_bus.name
  event_pattern = jsonencode({
    "source": ["customer-profile"],
    "detail-type": ["address.added"]
  })
}

resource "aws_cloudwatch_event_target" "invoke_add_address_lambda" {
  rule           = aws_cloudwatch_event_rule.bus_address_added.name
  event_bus_name = aws_cloudwatch_event_bus.address_bus.name
  arn            = var.add_address_function_arn 
  target_id      = "AddAddressHandler" # unique name, doesnt corealte with lambda handler
}


# DEFINE EVENT FOR EDIT ADDRESS FUNCTION
resource "aws_cloudwatch_event_rule" "bus_address_edited" {
  name           = "${var.stack_name}_address_edited"
  event_bus_name = aws_cloudwatch_event_bus.address_bus.name
  event_pattern = jsonencode({
    "source": ["customer-profile"],
    "detail-type": ["address.updated"]
  })
}

resource "aws_cloudwatch_event_target" "invoke_edited_address_lambda" {
  rule           = aws_cloudwatch_event_rule.bus_address_edited.name
  event_bus_name = aws_cloudwatch_event_bus.address_bus.name
  arn            = var.edit_address_function_arn # tu ma byc arn funkcji 
  target_id      = "AddAddressHandler" # unique name, doesnt corealte with lambda handler
}

# ZDEFINIOWAĆ RULE, TARGET ORAZ INWOKACJE DLA DELETE 
resource "aws_cloudwatch_event_rule" "bus_address_deleted" {
  name           = "${var.stack_name}_address_deleted"
  event_bus_name = aws_cloudwatch_event_bus.address_bus.name
  event_pattern = jsonencode({
    "source": ["customer-profile"],
    "detail-type": ["address.deleted"]
  })
}

resource "aws_cloudwatch_event_target" "invoke_delete_address_lambda" {
  rule           = aws_cloudwatch_event_rule.bus_address_deleted.name
  event_bus_name = aws_cloudwatch_event_bus.address_bus.name
  arn            = var.delete_address_function_arn # tu ma byc arn funkcji
  target_id      = "AddAddressHandler" # unique name, doesnt corealte with lambda handler
}