# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "rest_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "rest_api"
      version = "1.0"
    }
    components = {
      securitySchemes = {
        lambdaTokenAuthorizer = {
          type                         = "apiKey"
          name                         = "Authorization"
          in                           = "header"
          x-amazon-apigateway-authtype = "custom"
          x-amazon-apigateway-authorizer = {
            authorizerUri                = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_auth_name}/invocations"
            authorizerResultTtlInSeconds = 300
            type                         = "token"
          }
        }
      }
    }
    paths = {
      "/users" = {
        get = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.function_arn}/invocations"
          }
        },
        post = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.function_arn}/invocations"
          }
        }
      },
      "/users/{userid}" = {
        put = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.function_arn}/invocations"
          }
        },
        get = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.function_arn}/invocations"
          }
        },
        delete = {
          security = [
            {
              "lambdaTokenAuthorizer" : []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod = "POST"
            type       = "aws_proxy"
            uri        = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.function_arn}/invocations"
          }
        }
      }
    }
  })

  name = var.api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "rest_api" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#DODAJEMY LOGOWANIE DO STAGE NASZEGO API, role oraz ustawienia dla logownia skonfigurowane są w module global api settings
resource "aws_api_gateway_stage" "rest_api" { 
  depends_on = [var.aws_api_gateway_account_settings] # global api settings output here 
  deployment_id = aws_api_gateway_deployment.rest_api.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name = "Prod"
  xray_tracing_enabled = true
  access_log_settings {
    destination_arn = var.users_api_access_logs # log role ARN output from global api settings 
    format          = jsonencode({
      requestId         = "$context.requestId"
      ip                = "$context.identity.sourceIp"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      routeKey          = "$context.routeKey"
      status            = "$context.status"
      protocol          = "$context.protocol"
      integrationStatus = "$context.integrationStatus"
      integrationLatency = "$context.integrationLatency"
      responseLength    = "$context.responseLength"
    })
  }
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_lambda_auth" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_auth_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/authorizers/*"
}

