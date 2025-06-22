
data "aws_iam_policy_document" "apigateway_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
# dodatkowo musimy sobie jeszcze zrobic role attach - nawet dla roli managed terraform tego wymaga 
resource "aws_iam_role" "api_logging_role" {  
  name = "ApiLoggingRole"
  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role_policy.json
  path = "/"
}
# przytwierdzam politykę do roli zdefiniowanej powyżej, zgodnie  z dobrą praktyką terraform 
resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = aws_iam_role.api_logging_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "settings" {
  cloudwatch_role_arn = aws_iam_role.api_logging_role.arn
  reset_on_delete = true 
}

resource "aws_cloudwatch_log_group" "users_api_access_logs" {
  name              = "/${var.api_account_name}/users_api_logs"
  retention_in_days = 30

  depends_on = [aws_iam_role.api_logging_role]
}

resource "aws_cloudwatch_log_group" "orders_api_access_logs" {
  name              = "/${var.api_account_name}/orders_api_logs"
  retention_in_days = 30

  depends_on = [aws_iam_role.api_logging_role]
}

resource "aws_cloudwatch_log_group" "address_api_access_logs" {
  name              = "/${var.api_account_name}/address_api_logs"
  retention_in_days = 30

  depends_on = [aws_iam_role.api_logging_role]
}