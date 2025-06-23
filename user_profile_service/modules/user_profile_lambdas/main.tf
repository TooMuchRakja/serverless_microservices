data "aws_secretsmanager_secret_version" "bucket_name_secret" {
  secret_id = "my-bucket-name-secret-v2"
}

locals {
  lambda_code_bucket = jsondecode(data.aws_secretsmanager_secret_version.bucket_name_secret.secret_string).bucket_name
  }

resource "aws_lambda_function" "add_address_function" {
    
  function_name = "${var.add_address_function_name}"
  description   = "Lambda function to add address to DynamoDB table"
  role          = var.add_address_role_arn # do zmiany rola - podać arn kiedy już zdefinuiję poprawną rolę i uprawnienia
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "add_address_function.zip" # s3 key zawsze musi być w cudzysłowiu 

  environment {
    variables = {
      "ADDRESS_TABLE_NAME" = "${var.address_table_name}"
    }
  }

}

resource "aws_lambda_function" "edit_address_function" {
    
  function_name = "${var.edit_address_function_name}"
  description   = "Lambda function to edit address to DynamoDB table"
  role          = var.edit_address_role_arn # do zmiany rola - podać arn kiedy już zdefinuiję poprawną rolę i uprawnienia
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "edit_address_function.zip" # s3 key zawsze musi być w cudzysłowiu 

  environment {
    variables = {
      "ADDRESS_TABLE_NAME" = "${var.address_table_name}"
    }
  }

}

resource "aws_lambda_function" "delete_address_function" {
    
  function_name = "${var.delete_address_function_name}"
  description   = "Lambda function to add address to DynamoDB table"
  role          =  var.delete_address_role_arn # do zmiany rola - podać arn kiedy już zdefinuiję poprawną rolę i uprawnienia
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "delete_address_function.zip" # s3 key zawsze musi być w cudzysłowiu 

  environment {
    variables = {
      "ADDRESS_TABLE_NAME" = "${var.address_table_name}"
    }
  }

}

resource "aws_lambda_function" "list_address_function" {
    
  function_name = "${var.list_address_function_name}"
  description   = "Lambda function which returns addresses from dynamodb address table"
  role          =  var.list_address_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "list_address_function.zip" # s3 key zawsze musi być w cudzysłowiu 

  environment {
    variables = {
      "ADDRESS_TABLE_NAME" = "${var.address_table_name}"
    }
  }

}