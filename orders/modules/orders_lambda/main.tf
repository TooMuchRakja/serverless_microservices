# tutaj zdefinujemy sobie trzy funkcję lambda które będą działać nam na zasobach tabeli orders_table
data "aws_secretsmanager_secret_version" "bucket_name_secret" {
  secret_id = "my-bucket-name-secret-v2"
}

locals {
  lambda_code_bucket = jsondecode(data.aws_secretsmanager_secret_version.bucket_name_secret.secret_string).bucket_name
  }

resource "aws_lambda_function" "add_order_lambda" {
  function_name    = "${var.add_order_function_name}"
  description      = "Lambda function to add order to DynamoDB table"
  role             = "${var.add_order_function_role_arn}" # tutaj trzeba bedzie dołożyć rolę z modułu iam dla funkcji add
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout
  layers           = [aws_lambda_layer_version.requirements_layer.arn,
                      "arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"] # NAZEWNICTWO LAMBDA LAYERA JAK Z DOKUMENTACJI 
  s3_bucket = local.lambda_code_bucket
  s3_key    = "add_order_function.zip"

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      ORDERS_TABLE = "${var.orders_dynamodb_table_name}"
      IDEMPOTENCY_TABLE_NAME = "${var.idempotence_dynamodb_table_name}"
      POWERTOOLS_SERVICE_NAME = "${var.powertools_service_name}"
      POWERTOOLS_METRICS_NAMESPACE = "${var.powertools_namespace}"
    }
  }
}


resource "aws_lambda_function" "edit_order_lambda" {
  function_name    = "${var.edit_order_function_name}"
  description      = "Lambda function to edit order in DynamoDB table"
  role             = "${var.edit_order_function_role_arn}" # tutaj trzeba bedzie dołożyć rolę z modułu iam dla funkcji edit 
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout
  layers           = [aws_lambda_layer_version.requirements_layer.arn, aws_lambda_layer_version.get_order_layer.arn, 
                      "arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "edit_order_function.zip"

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      ORDERS_TABLE = "${var.orders_dynamodb_table_name}"
    }
  }
}

resource "aws_lambda_function" "delete_order_lambda" {
  function_name    = "${var.delete_order_function_name}"
  description      = "Lambda function to delete orders from DynamoDB table"
  role             = "${var.delete_order_function_role_arn}" # tutaj trzeba bedzie dołożyć rolę z modułu iam dla delete function 
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout
  layers           = [aws_lambda_layer_version.requirements_layer.arn, aws_lambda_layer_version.get_order_layer.arn, 
                      "arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]


  s3_bucket = local.lambda_code_bucket
  s3_key    = "delete_order_function.zip"

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      ORDERS_TABLE = "${var.orders_dynamodb_table_name}"
    }
  }
}

resource "aws_lambda_function" "get_order_lambda" {
  function_name    = "${var.get_order_function_name}"
  description      = "Lambda function to get order from DynamoDB table"
  role             = "${var.get_order_function_role_arn}" # tutaj trzeba bedzie dołożyć rolę z modułu iam 
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout
  layers           = [aws_lambda_layer_version.requirements_layer.arn, aws_lambda_layer_version.get_order_layer.arn, 
                      "arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${var.python_version}-x86_64:12"]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "get_order_function.zip"

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      ORDERS_TABLE = "${var.orders_dynamodb_table_name}"
    }
  }
}

resource "aws_lambda_function" "list_order_lambda" {
  function_name    = "${var.list_order_function_name}"
  description      = "Lambda function to list orders from DynamoDB table"
  role             = "${var.list_order_function_role_arn}" # tutaj trzeba bedzie dołożyć rolę z modułu iam 
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory
  timeout          = var.lambda_timeout
  layers           = [aws_lambda_layer_version.requirements_layer.arn]

  s3_bucket = local.lambda_code_bucket
  s3_key    = "list_order_function.zip"

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      ORDERS_TABLE = "${var.orders_dynamodb_table_name}"
    }
  }
}

# TWORZENIE LAMBDA LAYER DLA REQUIREMENTS 
resource "aws_lambda_layer_version" "requirements_layer" {
  layer_name = "requirements_layer"
  s3_bucket = local.lambda_code_bucket
  s3_key = "requirements_layer.zip"
  compatible_runtimes = ["python3.10"]
}

#TWORZENIE LAMBDA LAYER DLA FUNKCJI GET - BĘDZIE ONA UZYWANA PRZEZ KILKA FUNKCJI - GET, EDIT, DELETE
resource "aws_lambda_layer_version" "get_order_layer" {
  layer_name = "get_order_layer"
  s3_bucket = local.lambda_code_bucket
  s3_key = "get_order_layer.zip"
  compatible_runtimes = ["python3.10"]
}
