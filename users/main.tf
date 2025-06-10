
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "cloudwatch_dashboard" {
  source = "./modules/cloudwatch_dashboard"
  dashboard_name = "${var.stack_name}-dashboard"
  function_name = module.lambda.lambda_function_name
  region = var.region
  lambda_auth_name = module.lambda_authorizer.lambda_auth_name
  api_gateway_name = module.api-gateway.api_name
}

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch_alarms"
  sns_topic_arn = module.sns.sns_topic_arn
  lambda_function_name = module.lambda.lambda_function_name
  lambda_auth_name = module.lambda_authorizer.lambda_auth_name
  api_gateway_name = module.api-gateway.api_name
}

module "sns" {
    source = "./modules/sns"
    sns_topic_name = "${var.stack_name}-sns-alarm-topic"
    sns_email = var.sns_email
}

module "lambda_authorizer" {
    source = "./modules/lambda_iam_auth"
    function_name = "${var.stack_name}-lambda-authorizer"
    role_name = "${var.stack_name}-lambda-authorizer-role"
    role_policy = "${var.stack_name}-authorizer_policy"
    auth_policy_attachment = "${var.stack_name}-auth_policy_attachment"
    cognito_user_pool = module.cognito.UserPool
    user_pool_client = module.cognito.UserPoolClient
    user_pool_admin_group_name = module.cognito.UserPoolAdminGroupName

}

module "cognito" {
    source = "./modules/cognito"
    region =  var.region
    cognito_user_pool_name = "${var.stack_name}-user-pool"
    cognito_user_pool_client_name = "${var.stack_name}-client"
    user_pool_admin_group_name = "${var.stack_name}-apiAdmins"
    cognito_user_pool_domain = "${var.stack_name}-domain"
}

module  "api-gateway"  {
    source = "./modules/apigateway"
    region =  var.region
    function_name = module.lambda.lambda_function_name
    function_arn = module.lambda.lambda_function_arn
    api_name  = "${var.stack_name}-api"
    auth_function_arn = module.lambda_authorizer.auth_function_arn
    lambda_auth_name = module.lambda_authorizer.lambda_auth_name
    api_account_name = var.stack_name
    global_api_logging_role_arn = var.global_api_logging_role_arn
    users_api_access_logs = var.users_api_access_logs
    aws_api_gateway_account_settings = var.aws_api_gateway_account_settings
}

module "dynamodb" {
    source = "./modules/dynamodb"
    table_name = "${var.stack_name}-dynbamodb" # tutaj nadaje nazwe zmiennej z modulu - tam jest table_name
}

module "lambda" {
  source = "./modules/lambda"
  function_name = "${var.stack_name}-lambda"
  table_name = module.dynamodb.dynamodb_table_name # tu juz nawiazujemy tylko do konkretnej nazwy outputa z podmodulow 
  lambda_role_arn = module.iam.lambda_role_arn # to jest output z modulu dynamodb, czyli id tabeli, id zostnie przekazane do funkcji lambda jako zmienna 
}

module "iam" {
    source = "./modules/iam"
    region =  var.region
    function_name = module.lambda.lambda_function_name
    role_name = "${var.stack_name}-iam"
    table_name = module.dynamodb.dynamodb_table_name # tu juz nawiazujemy tylko do konkretnej nazwy outputa z podmodulow 
}
