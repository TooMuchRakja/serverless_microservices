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
            credentials         = aws_iam_role.address_api_role.arn # ROLA KTORA UPRAWNIA API DO DODAWANIA DO EVENTS 
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
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{}"
                }
              }
            }
          }
          requestBody = {
            required = true
            content = {
              "application/json" = {
                schema = {
                  "$ref" = "#/components/schemas/UserAddressInputModel"
                }
              }
            }
          }
          parameters = [
            {
              name   = "Content-Type"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name   = "X-Amz-Target"
              in     = "header"
              schema = { type = "string" }
            }
          ]
        }
      }

      "/address/{addressId}" = {
        put = {
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws" # TYPE AWS OZNACZA NON PROXY INTEGRATION, UZYWANE DLA NON PROXY INTEGRATION 
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
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{}"
                }
              }
            }
          }
          parameters = [
            {
              name   = "Content-Type"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name   = "X-Amz-Target"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name     = "addressId"
              in       = "path"
              required = true
              schema   = { type = "string" }
            }
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
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{}"
                }
              }
            }
          }
          parameters = [
            {
              name   = "Content-Type"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name   = "X-Amz-Target"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name     = "addressId"
              in       = "path"
              required = true
              schema   = { type = "string" }
            }
          ]
        }
      }

      "/favourites" = {
        get = {
          security = [{ CognitoAuthorizer = [] }]
          responses = {
            "200" = {
              description = "200 response"
            }
          }
          "x-amazon-apigateway-integration" = {
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.list_favourites_function_arn}/invocations"
            passthroughBehavior = "when_no_match"
            type                = "aws_proxy"
          }
        }
        post = {
          parameters = [
            {
              name   = "Content-Type"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name   = "X-Amz-Target"
              in     = "header"
              schema = { type = "string" }
            }
          ]
          responses = {
            "200" = {
              description = "200 response"
              content = {
                "application/json" = {
                  schema = {
                    "$ref" = "#/components/schemas/Empty"
                  }
                }
              }
            }
          }
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            credentials         = aws_iam_role.address_api_role.arn # ta sama rola, mam w niej uprawnienia dla events oraz sqs
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${var.favourites_sqs_queue_name}" # tutaj nalezy podac queue name
            passthroughBehavior = "never"
            type                = "aws"
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
                &Version=2012-11-05
              EOF
            }
          }
        }
      }

      "/favourites/{restaurantId}" = {
        delete = {
          parameters = [
            {
              name   = "Content-Type"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name   = "X-Amz-Target"
              in     = "header"
              schema = { type = "string" }
            },
            {
              name     = "restaurantId"
              in       = "path"
              required = true
              schema   = { type = "string" }
            }
          ]
          responses = {
            "200" = {
              description = "200 response"
              content = {
                "application/json" = {
                  schema = {
                    "$ref" = "#/components/schemas/Empty"
                  }
                }
              }
            }
          }
          security = [{ CognitoAuthorizer = [] }]
          "x-amazon-apigateway-integration" = {
            credentials         = aws_iam_role.address_api_role.arn 
            httpMethod          = "POST"
            uri                 = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${var.favourites_sqs_queue_name}" 
            responses = {
              default = {
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{}"
                }
              }
            }
            requestParameters = {
              "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
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
          "sqs:SendMessage"
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
