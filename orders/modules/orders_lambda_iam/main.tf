
data "aws_caller_identity" "current" {}

# ADD FUNCTION ROLE AND POLICY - FUNCTION ALLOWED TO ADD NEW ITEMS TO DDB TABLE 
resource "aws_iam_role" "add_order_function_role" {
  name = "${var.add_order_function_name}-role"
  description = "Add order Lambda function IAM role"
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
resource "aws_iam_policy" "add_order_function_policy" {
  name        = "${var.add_order_function_name}-policy"
  description = "Add order Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:DescribeTable",
        "dynamodb:ConditionCheckItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.orders_dynamodb_table_name}"
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
resource "aws_iam_policy_attachment" "add_order_function_attach" {
  name       = "${var.add_order_function_name}-lambda_attachment"
  roles      = [aws_iam_role.add_order_function_role.name] # tutaj wymagana jest nazwa jako string
  policy_arn = aws_iam_policy.add_order_function_policy.arn
}

# EDIT FUNCTION ROLE AND POLICY - FUNCTION ALLOWED TO EDIT A SINGLE ELEMENT IN DDB TABLE BASED ON ORDER ID 
resource "aws_iam_role" "edit_order_function_role" {
  name = "${var.edit_order_function_name}-role"
  description = "Edit order Lambda function IAM role"
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
resource "aws_iam_policy" "edit_order_function_policy" {
  name        = "${var.edit_order_function_name}-policy"
  description = "Edit order Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:UpdateItem",
        "dynamodb:GetItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.orders_dynamodb_table_name}"
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
resource "aws_iam_policy_attachment" "edit_order_function_attach" {
  name       = "${var.edit_order_function_name}-lambda_attachment"
  roles      = [aws_iam_role.edit_order_function_role.name]
  policy_arn = aws_iam_policy.edit_order_function_policy.arn
}


# DELETE FUNCTION ROLE AND POLICY - FUNCTION ALLOWED TO DELETE ORDER FROM DDB TABLE BASED ON ORDER ID 
resource "aws_iam_role" "delete_order_function_role" {
  name = "${var.delete_order_function_name}-role"
  description = "Delete order Lambda function IAM role"
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
resource "aws_iam_policy" "delete_order_function_policy" {
  name        = "${var.delete_order_function_name}-policy"
  description = "Delete order Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.orders_dynamodb_table_name}"
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
resource "aws_iam_policy_attachment" "delete_order_function_attach" {
  name       = "${var.delete_order_function_name}-lambda_attachment"
  roles      = [aws_iam_role.delete_order_function_role.name]
  policy_arn = aws_iam_policy.delete_order_function_policy.arn
}

# GET FUNCTION ROLE AND POLICY - FUNCTION WILL TAKE SINGLE ELEMENT FROM DDB TABLE BASED ON ORDER ID 
resource "aws_iam_role" "get_order_function_role" {
  name = "${var.get_order_function_name}-role"
  description = "Get order Lambda function IAM role"
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
resource "aws_iam_policy" "get_order_function_policy" {
  name        = "${var.get_order_function_name}-policy"
  description = "Get order Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:GetItem",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.orders_dynamodb_table_name}"
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
resource "aws_iam_policy_attachment" "get_order_function_attach" {
  name       = "${var.get_order_function_name}-lambda_attachment"
  roles      = [aws_iam_role.get_order_function_role.name]
  policy_arn = aws_iam_policy.get_order_function_policy.arn
}


# LIST FUNCTION ROLE AND POLICY - FUNCTION WILL TAKE ALL ELEMENTS FROM DDB TABLE 
resource "aws_iam_role" "list_order_function_role" {
  name = "${var.list_order_function_name}-role"
  description = "List Lambda function IAM role"
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
resource "aws_iam_policy" "list_order_function_policy" {
  name        = "${var.list_order_function_name}-policy"
  description = "Get order Lambda function policy"

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
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.orders_dynamodb_table_name}"
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
  name       = "${var.list_order_function_name}-lambda_attachment"
  roles      = [aws_iam_role.list_order_function_role.name]
  policy_arn = aws_iam_policy.list_order_function_policy.arn
}