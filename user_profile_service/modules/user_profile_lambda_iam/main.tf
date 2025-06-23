
data "aws_caller_identity" "current" {}

# ADD ADDRESS FUNCTION ROLE AND POLICY - FUNCTION ALLOWED TO ADD NEW ADRESSES TO DDB TABLE 
resource "aws_iam_role" "add_address_function_role" {
  name = "${var.add_address_function_name}-role" 
  description = "Add address Lambda function IAM role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "add_address_function_policy" {
  name        = "${var.add_address_function_name}-policy" 
  description = "Add address Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DescribeTable",
        "dynamodb:ConditionCheckItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.address_table_name}"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"


      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "add_address_function_attach" {
  name       = "${var.add_address_function_name}-lambda_attachment"
  roles      = [aws_iam_role.add_address_function_role.name] 
  policy_arn = aws_iam_policy.add_address_function_policy.arn
}

# EDIT ADDRESS FUNCTION ROLE AND POLICY  
resource "aws_iam_role" "edit_address_function_role" {
  name = "${var.edit_address_function_name}-role"
  description = "Edit address Lambda function IAM role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "edit_address_function_policy" {
  name        = "${var.edit_address_function_name}-policy"
  description = "Edit address Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:GetItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.address_table_name}"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "edit_address_function_attach" {
  name       = "${var.edit_address_function_name}-lambda_attachment"
  roles      = [aws_iam_role.edit_address_function_role.name]
  policy_arn = aws_iam_policy.edit_address_function_policy.arn
}


# DELETE ADDRESS ROLE AND POLICY 
resource "aws_iam_role" "delete_address_function_role" {
  name = "${var.delete_address_function_name}-role"
  description = "Delete address Lambda function IAM role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "delete_address_function_policy" {
  name        = "${var.delete_address_function_name}-policy"
  description = "Delete address Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:GetItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.address_table_name}"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "delete_address_function_attach" {
  name       = "${var.delete_address_function_name}-lambda_attachment"
  roles      = [aws_iam_role.delete_address_function_role.name]
  policy_arn = aws_iam_policy.delete_address_function_policy.arn
}

# PERMISSION FOR LIST ORDER FUNCTION 
resource "aws_iam_role" "list_address_function_role" {
  name = "${var.list_address_function_name}-role"
  description = "Role which allows list address lambda to perform required tasks"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "list_address_function_policy" {
  name        = "${var.list_address_function_name}-policy"
  description = "List address lambda policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.address_table_name}"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "list_order_function_attach" {
  name       = "${var.list_address_function_name}-lambda_attachment"
  roles      = [aws_iam_role.list_address_function_role.name]
  policy_arn = aws_iam_policy.list_address_function_policy.arn
}

#API GATEWAY PERMISSION FOR INVOKING LIST ORDER LAMBDA 
resource "aws_lambda_permission" "list_address_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayListOrders"
  action        = "lambda:InvokeFunction"
  function_name = var.list_address_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.address_api_source_arn}/prod/GET/address"
}

