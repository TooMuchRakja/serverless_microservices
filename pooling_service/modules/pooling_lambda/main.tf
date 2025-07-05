
data "aws_secretsmanager_secret_version" "bucket_name_secret" {
  secret_id = "my-bucket-name-secret-v2"
}

locals {
  lambda_code_bucket = jsondecode(data.aws_secretsmanager_secret_version.bucket_name_secret.secret_string).bucket_name
  }

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "update_pooling_function" {
    
  function_name = "${var.update_pooling_function_name}"
  description   = "Pooling Lambda function to update orders from DynamoDB orders table "
  role          = var.add_favourites_role_arn # do zmiany 
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "update_pooling_function.zip" 

  environment {
    variables = {
      "ORDERS_TABLE" = "${var.orders_dynamodb_table_name}"
    }
  }
  
  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
  }
}


resource "aws_iam_role" "update_pooling_function_role" {
  name = "${var.update_pooling_function_name}-role"
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

resource "aws_iam_policy" "update_pooling_function_policy" {
  name   = "${var.update_pooling_function_name}-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:DescribeTable",
        "dynamodb:ConditionCheckItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.orders_dynamodb_table_name}" 

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
  name       = "${var.update_pooling_function_name}-lambda_attachment"
  roles      = [aws_iam_role.update_pooling_function_role.name] # tutaj wymagana jest nazwa jako string
  policy_arn = aws_iam_policy.update_pooling_function_policy.arn
}