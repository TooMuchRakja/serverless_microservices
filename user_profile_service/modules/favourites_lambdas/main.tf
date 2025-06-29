# LAMBDA FUNCTIONS FOR FAVOURITES MODULE - FIRST DO ADD FAVOURITE RESTAURANT TO TABLE, SECOND TO LIST ALL FAVOURITES

data "aws_secretsmanager_secret_version" "bucket_name_secret" {
  secret_id = "my-bucket-name-secret-v2"
}

locals {
  lambda_code_bucket = jsondecode(data.aws_secretsmanager_secret_version.bucket_name_secret.secret_string).bucket_name
  }

resource "aws_lambda_function" "add_favourites_function" {
    
  function_name = "${var.add_favourites_function_name}"
  description   = "Lambda function to add favourite restaurant to favourites DynamoDB table"
  role          = var.add_favourites_role_arn 
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "add_favourites_function.zip" # s3 key zawsze musi być w cudzysłowiu 

  environment {
    variables = {
      "FAVOURITES_TABLE_NAME" = "${var.favourites_dynamodb_table_name}"
    }
  }
  
  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_lambda_function" "list_favourites_function" {
  function_name = "${var.list_favourites_function_name}"
  description   = "Lambda function to list favourite restaurant to favourites DynamoDB table"
  role          = var.list_favourites_role_arn 
  handler       = "lambda_function.lambda_handler" # nazwa pliku funkcji bez py.nazwa handlera
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  layers        = ["arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "list_favourites_function.zip"

  environment {
    variables = {
      "FAVOURITES_TABLE_NAME" = "${var.favourites_dynamodb_table_name}"
    }
  }

  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
  }
}
