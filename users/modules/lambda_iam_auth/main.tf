# w tym pliku skonfiguruję sobie authorizer lambda 
# wraz z authorizerem będę miał tutaj definicję uprawnień iam dla tej funkcji 

data "aws_secretsmanager_secret_version" "bucket_name_secret" {
  secret_id = "my-bucket-name-secret-v2"
}

locals {
  lambda_code_bucket = jsondecode(data.aws_secretsmanager_secret_version.bucket_name_secret.secret_string).bucket_name
  }

resource "aws_lambda_function" "userfunctions_lambda_auth" {
  function_name    = var.function_name
  description      = "Handler for Lambda authorizer"
  role             = aws_iam_role.userfunctions_lambda_auth_role.arn #arn roli zdefiniowanej ponizej, nie jest tutaj outputem wiec musze podac pełną treść, bo wszystko mam w tym samym stacku 
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  s3_bucket = local.lambda_code_bucket
  s3_key    = "authorizer_function.zip" # pakowanie tez na poziomie workflow 

  environment {
    variables = {
      USER_POOL_ID          = var.cognito_user_pool  
      APPLICATION_CLIENT_ID = var.user_pool_client
      ADMIN_GROUP_NAME      = var.user_pool_admin_group_name
    }
  }
}

# rola iam dla lambda authorizer 

resource "aws_iam_role" "userfunctions_lambda_auth_role" {
  name               = var.role_name
  description        = "Lambda function authorizer IAM role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "userfunctions_lambda_auth_role_policy" {
  name        = var.role_policy
  description = "Lambda function authorizer policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "xray:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "userfunctions_lambda_auth_attach" {
  name       = var.auth_policy_attachment
  roles      = ["${aws_iam_role.userfunctions_lambda_auth_role.name}"]
  policy_arn = aws_iam_policy.userfunctions_lambda_auth_role_policy.arn
}
