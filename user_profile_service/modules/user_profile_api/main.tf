data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "address_api" {
  name = "serverless-workshop-address-API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title       = "Address API"
      version     = "1.0.0"
      description = "Address management API, secured with Cognito authorizer"
    }
    components = {
      schemas = {
        Empty = {
          title = "Empty Schema"
          type  = "object"
        }
        UserAddressInputModel = {
          required = ["city", "line1", "line2", "postal", "stateProvince"]
          type     = "object"
          properties = {
            line1         = { type = "string" }
            line2         = { type = "string" }
            city          = { type = "string" }
            stateProvince = { type = "string" }
            postal        = { type = "string" }
          }
        }
      }
      securitySchemes = {
        CognitoAuthorizer = {
          type                           = "apiKey"
          name                           = "Authorization"
          in                             = "header"
          x-amazon-apigateway-authtype   = "cognito_user_pools"
          x-amazon-apigateway-authorizer = {
            type         = "cognito_user_pools"
            providerARNs = ["arn:aws:cognito-idp:${var.region}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"]
          }
        }
      }
    }
    "x-amazon-apigateway-request-validators" = {
      "Validate body" = {
        validateRequestParameters = false
        validateRequestBody       = true
      }
    }
    paths = {
      "/address" = {
        get = {
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            type                  = "aws_proxy"
            httpMethod            = "POST"
            uri                   = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.list_address_function_arn}/invocations"
            passthroughBehavior   = "when_no_match"
            integrationHttpMethod = "POST"
          }
          responses = {
            "200" = {
              description = "Successful response"
              content = {
                "application/json" = {
                  schema = {
                    type  = "array"
                    items = {
                      type = "object"
                    }
                  }
                }
              }
            }
          }
        }
        post = {
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws"
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:events:action/PutEvents"
            credentials         = aws_iam_role.address_api_role.arn
            passthroughBehavior = "when_no_templates"
            requestTemplates = {
              "application/json" = <<-EOF
                #set($context.requestOverride.header.X-Amz-Target = "AWSEvents.PutEvents")
                #set($context.requestOverride.header.Content-Type = "application/x-amz-json-1.1")
                #set($inputRoot = $input.path("$"))
                {
                  "Entries":[
                    {
                      "Detail": "{#foreach($paramName in $inputRoot.keySet())\"$paramName\" : \"$util.escapeJavaScript($inputRoot.get($paramName))\" #if($foreach.hasNext),#end #end,\"userId\": \"$context.authorizer.claims.sub\"}",
                      "DetailType":"address.added",
                      "EventBusName":"${var.address_bus_name}",
                      "Source":"customer-profile"
                    }
                  ]
                }
              EOF
            }
            responses = {
              default = {
                statusCode        = "200"
                responseTemplates = { "application/json" = "{}" }
              }
            }
          }
          requestBody = {
            required = true
            content = {
              "application/json" = {
                schema = { "$ref" = "#/components/schemas/UserAddressInputModel" }
              }
            }
          }
          parameters = [
            { name = "Content-Type", in = "header", schema = { type = "string" } },
            { name = "X-Amz-Target", in = "header", schema = { type = "string" } }
          ]
        }
      }
      "/address/{addressId}" = {
        put = {
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws"
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:events:action/PutEvents"
            credentials         = aws_iam_role.address_api_role.arn
            passthroughBehavior = "when_no_templates"
            requestTemplates = {
              "application/json" = <<-EOF
                #set($context.requestOverride.header.X-Amz-Target = "AWSEvents.PutEvents")
                #set($context.requestOverride.header.Content-Type = "application/x-amz-json-1.1")
                #set($inputRoot = $input.path("$"))
                {
                  "Entries":[
                    {
                      "Detail": "{#foreach($paramName in $inputRoot.keySet())\"$paramName\" : \"$util.escapeJavaScript($inputRoot.get($paramName))\" #if($foreach.hasNext),#end #end,\"userId\": \"$context.authorizer.claims.sub\",\"addressId\": \"$input.params().get('path').get('addressId')\"}",
                      "DetailType":"address.updated",
                      "EventBusName":"${var.address_bus_name}",
                      "Source":"customer-profile"
                    }
                  ]
                }
              EOF
            }
            responses = {
              default = {
                statusCode        = "200"
                responseTemplates = { "application/json" = "{}" }
              }
            }
          }
          parameters = [
            { name = "Content-Type", in = "header", schema = { type = "string" } },
            { name = "X-Amz-Target", in = "header", schema = { type = "string" } },
            { name = "addressId", in = "path", required = true, schema = { type = "string" } }
          ]
        }
        delete = {
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws"
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:events:action/PutEvents"
            credentials         = aws_iam_role.address_api_role.arn
            passthroughBehavior = "when_no_templates"
            requestTemplates = {
              "application/json" = <<-EOF
                #set($context.requestOverride.header.X-Amz-Target = "AWSEvents.PutEvents")
                #set($context.requestOverride.header.Content-Type = "application/x-amz-json-1.1")
                {
                  "Entries":[
                    {
                      "Detail": "{\"userId\": \"$context.authorizer.claims.sub\",\"addressId\": \"$input.params().get('path').get('addressId')\"}",
                      "DetailType":"address.deleted",
                      "EventBusName":"${var.address_bus_name}",
                      "Source":"customer-profile"
                    }
                  ]
                }
              EOF
            }
            responses = {
              default = {
                statusCode        = "200"
                responseTemplates = { "application/json" = "{}" }
              }
            }
          }
          parameters = [
            { name = "Content-Type", in = "header", schema = { type = "string" } },
            { name = "X-Amz-Target", in = "header", schema = { type = "string" } },
            { name = "addressId", in = "path", required = true, schema = { type = "string" } }
          ]
        }
      }
      "/favourites" = {
        get = {
          security = [{ CognitoAuthorizer = [] }]
          responses = {
            "200" = { description = "200 response" }
          }
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.list_favourites_function_arn}/invocations"
            passthroughBehavior = "when_no_match"
          }
        }
        post = {
          security = [{ CognitoAuthorizer = [] }]
          parameters = [
            { name = "Content-Type", in = "header", schema = { type = "string" } },
            { name = "X-Amz-Target", in = "header", schema = { type = "string" } }
          ]
          requestBody = {
            required = true
            content = {
              "application/json" = {
                schema = { "$ref" = "#/components/schemas/Empty" }
              }
            }
          }
          responses = {
            "200" = {
              description = "200 response"
              content = {
                "application/json" = {
                  schema = { "$ref" = "#/components/schemas/Empty" }
                }
              }
            }
          }
          "x-amazon-apigateway-integration" = {
            type                = "aws"
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${var.favourites_sqs_queue_name}"
            credentials         = aws_iam_role.address_api_role.arn
            passthroughBehavior = "never"
            requestParameters = {
              "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
            }
            requestTemplates = {
              "application/json" = <<-EOF
                Action=SendMessage
                &MessageBody=$input.path('$.restaurantId')
                &MessageAttributes.1.Name=CommandName
                &MessageAttributes.1.Value.StringValue=AddFavorite
                &MessageAttributes.1.Value.DataType=String
                &MessageAttributes.2.Name=UserId
                &MessageAttributes.2.Value.StringValue=$context.authorizer.claims.sub
                &MessageAttributes.2.Value.DataType=String
              EOF
            }
            responses = {
              default = {
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{}"
                }
              }
            }
          }
        }
      }
      "/favourites/{restaurantId}" = {
        delete = {
          security = [{ CognitoAuthorizer = [] }]
          parameters = [
            { name = "restaurantId", in = "path", required = true, schema = { type = "string" } }
          ]
          "x-amazon-apigateway-integration" = {
            type                = "aws"
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${var.favourites_sqs_queue_name}"
            credentials         = aws_iam_role.address_api_role.arn
            passthroughBehavior = "never"
            requestParameters = {
              "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
            }
            requestTemplates = {
              "application/json" = <<-EOF
                Action=SendMessage
                &MessageBody=$input.params('restaurantId')
                &MessageAttributes.1.Name=CommandName
                &MessageAttributes.1.Value.StringValue=RemoveFavorite
                &MessageAttributes.1.Value.DataType=String
                &MessageAttributes.2.Name=UserId
                &MessageAttributes.2.Value.StringValue=$context.authorizer.claims.sub
                &MessageAttributes.2.Value.DataType=String
              EOF
            }
            responses = {
              default = {
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{}"
                }
              }
            }
          }
        }
      }
    }
  })
}

resource "aws_api_gateway_deployment" "address_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.address_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.address_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "address_stage" {
  stage_name    =  "prod"
  depends_on    = [var.aws_api_gateway_account_settings]
  rest_api_id   = aws_api_gateway_rest_api.address_api.id
  deployment_id = aws_api_gateway_deployment.address_api_deploy.id

  access_log_settings {
    destination_arn = var.address_api_access_logs_arn
    format = jsonencode({
      requestId               = "$context.requestId"
      httpMethod              = "$context.httpMethod"
      ip                      = "$context.identity.sourceIp"
      resourcePath            = "$context.resourcePath"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  xray_tracing_enabled = true
}

resource "aws_iam_role" "address_api_role" {
  name = "address_api_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}
# ROLE WITH ADD EVENTS WITH SPECIFIC BUS PERMISSION & SEND MESSAGES TO SPECIFIC SQS QUEUE
resource "aws_iam_policy" "address_api_role_policy" {
  name = "address_api_role_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowPutEvents"
        Action = [
          "events:PutEvents"
        ]
        Effect = "Allow"
        Resource = "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.address_bus_name}"
      },
      {
        Sid = "AllowSendMessageToFavouritesQueue"
        Effect = "Allow"
        Action = [ 
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "${var.favourites_sqs_queue_arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "address_api_attachment" {
  role       = aws_iam_role.address_api_role.name
  policy_arn = aws_iam_policy.address_api_role_policy.arn
}

resource "aws_lambda_permission" "list_favourites_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayDeleteOrder"
  action        = "lambda:InvokeFunction"
  function_name = var.list_favourites_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.address_api.execution_arn}/prod/GET/favourites"
}

#poniżej wywołanie musi być dla sqs i source arn to arn kolejki a nie api - wtedy się to logicznie nie zgra 
resource "aws_lambda_permission" "sqs_queue_lambda_permission" {
  statement_id  = "AllowSQSToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.add_favourites_function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.favourites_sqs_queue_arn
}


