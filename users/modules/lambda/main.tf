
# będę musiał przerobić te funkcję lambda pod ci/cd - chcę aby zipy były budowane podczas workflow
# dodatkowo w lambdzie zamiast budować zależności lokalnie trzeba będzie wskazać wiaderko do którego zostanie spakowany kod 
# pobieram nazwe wiaderka w sekrecie 
data "aws_secretsmanager_secret_version" "bucket_name_secret" {
  secret_id = "my-bucket-name-secret-v2"
}
# zamiast zmiennej użyjemy locals - czemu locals odnosi się już do czegoś co istnieje i nie jest elastyczne 
# zmienna jest elastyczna i można ją modyfikowac locals nie 
locals {
  lambda_code_bucket = jsondecode(data.aws_secretsmanager_secret_version.bucket_name_secret.secret_string).bucket_name
  }
  

# wyrzucam stad source code hash, bede obliczal go na poziomie workflowa
resource "aws_lambda_function" "userfunctions_lambda" {
  function_name    = "${var.function_name}-szymon" 
  description      = "Handler for all users related operations"
  role             = var.lambda_role_arn # zrobic output z iam 
  handler          = "lambda_function.lambda_handler"
  memory_size      = var.lambda_memory #zamiast lambda_memory jest memory_size
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout

  s3_bucket = local.lambda_code_bucket
  s3_key    = "userfunction.zip" # pakowanie tez na poziomie workflow 

  tracing_config {
    mode = var.lambda_tracing_config
  }
  environment {
    variables = {
      USERS_TABLE = "${var.table_name}"
    }
  }
}

