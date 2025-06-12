data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# DODAĆ POPRAWNE WARTOŚCI DO API GATEWAY 

resource "aws_api_gateway_rest_api" "orders_api" {
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  name = "serverless-workshop-OrdersAPI" #nazwaAPI
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title       = "Orders API"
      version     = "1.0.0"
      description = "API do zarządzania zamówieniami, zabezpieczone za pomocą Amazon Cognito JWT"
    }
    paths = {
      "/orders" = {
        get = {
          summary  = "Pobierz wszystkie zamówienia (tylko dla administratorów)"
          tags     = ["Orders"]
          security = [{ CognitoAuthorizer = [] }]
          responses = {
            "200" = {
              description = "Lista wszystkich zamówień"
              content = {
                "application/json" = {
                  schema = {
                    "$ref" = "#/components/schemas/OrderList" #pobiera całą listę 
                  }
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.list_order_function_arn}/invocations"
            httpMethod           = "POST"
            type                 = "aws_proxy"
            payloadFormatVersion = "1.0"
          }
        },
        post = {
          summary  = "Dodaj zamówienie"
          tags     = ["Orders"]
          security = [{ CognitoAuthorizer = [] }]
          requestBody = {
            required = true
            content = {
              "application/json" = {
                schema = {
                  "$ref" = "#/components/schemas/NewOrder" # dodaje nowe zamowienie 
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "Zamówienie dodane"
              content = {
                "application/json" = {
                  schema = {
                    "$ref" = "#/components/schemas/Order"
                  }
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.add_order_function_arn}/invocations"
            httpMethod           = "POST"
            type                 = "aws_proxy"
            payloadFormatVersion = "1.0"
          }
        }
      },
      "/orders/{orderId}" = {
        get = {
          summary  = "Pobierz jedno zamówienie po ID"
          tags     = ["Orders"]
          security = [{ CognitoAuthorizer = [] }]
          parameters = [
            {
              name     = "orderId"
              in       = "path"
              required = true
              schema   = { type = "string" }
            }
          ]
          responses = {
            "200" = {
              description = "Szczegóły pojedynczego zamówienia"
              content = {
                "application/json" = {
                  schema = {
                    "$ref" = "#/components/schemas/Order" # tutaj pobiera cale zamowinie - odpowiedz serwera - czyli do neworder dodawane jest jescze order
                  }
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.get_order_function_arn}/invocations"
            httpMethod           = "POST"
            type                 = "aws_proxy"
            payloadFormatVersion = "1.0"
          }
        },
        put = {
          summary  = "Edytuj zamówienie po ID"
          tags     = ["Orders"]
          security = [{ CognitoAuthorizer = [] }]
          parameters = [
            {
              name     = "orderId"
              in       = "path"
              required = true
              schema   = { type = "string" }
            }
          ]
          requestBody = {
            required = true
            content = {
              "application/json" = {
                schema = {
                  "$ref" = "#/components/schemas/NewOrder"
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "Zamówienie zaktualizowane"
              content = {
                "application/json" = {
                  schema = {
                    "$ref" = "#/components/schemas/Order"
                  }
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.edit_order_function_arn}/invocations"
            httpMethod           = "POST"
            type                 = "aws_proxy"
            payloadFormatVersion = "1.0"
          }
        },
        delete = {
          summary  = "Usuń zamówienie po ID"
          tags     = ["Orders"]
          security = [{ CognitoAuthorizer = [] }]
          parameters = [
            {
              name     = "orderId"
              in       = "path"
              required = true
              schema   = { type = "string" }
            }
          ]
          responses = {
            "200" = {
              description = "Zamówienie usunięte"
              content = {
                "application/json" = {
                  schema = {
                    type = "object"
                  }
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.delete_order_function_arn}/invocations"
            httpMethod           = "POST"
            type                 = "aws_proxy"
            payloadFormatVersion = "1.0"
          }
        }
      }
    }
    components = {
      securitySchemes = {
        CognitoAuthorizer = {
          type = "apiKey"
          name = "Authorization"
          in   = "header"
          x-amazon-apigateway-authorizer = {
            type                         = "cognito_user_pools"
            identitySource               = "method.request.header.Authorization"
            providerARNs = [
              "arn:aws:cognito-idp:${var.region}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"
            ]
          }
          x-amazon-apigateway-authtype = "cognito_user_pools"
        }
      },
      schemas = {
        NewOrder = {
          type     = "object"
          required = ["orderId", "restaurantId", "totalAmount", "orderItems"]
          properties = {
            orderId      = { type = "string", format = "uuid" }
            restaurantId = { type = "string" }
            totalAmount  = { type = "number" }
            orderItems = {
              type = "array"
              items = {
                type = "object"
                properties = {
                  itemId   = { type = "string" }
                  quantity = { type = "integer" }
                }
              }
            }
          }
        },
        Order = {
          allOf = [
            { "$ref" = "#/components/schemas/NewOrder" },
            {
              type = "object"
              properties = {
                userId    = { type = "string" }
                status    = { type = "string", example = "PLACED" }
                orderTime = { type = "string", format = "date-time" }
              }
            }
          ]
        },
        OrderList = {
          type  = "array"
          items = { "$ref" = "#/components/schemas/Order" }
        }
      }
    }
  })
}
# deployment mrozi aktualny stan api gateway czyli ścieżek (resources) - kluczowy zasób, bez niego nie będzie online 
resource "aws_api_gateway_deployment" "orders_deploy" {
  rest_api_id = aws_api_gateway_rest_api.orders_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.orders_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#DODAJEMY LOGOWANIE DO STAGE NASZEGO API, role oraz ustawienia dla logownia skonfigurowane są w module global api settings
resource "aws_api_gateway_stage" "orders_stage" {
  depends_on    = [var.aws_api_gateway_account_settings] # global api settings output
  rest_api_id   = aws_api_gateway_rest_api.orders_api.id # to jest ok  
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.orders_deploy.id
  access_log_settings {
    destination_arn = var.orders_api_access_logs # global api settings orders log role arn output  
    format = jsonencode({
      requestId               = "$context.requestId"
      httpMethod              = "$context.httpMethod"
      ip                = "$context.identity.sourceIp"
      resourcePath            = "$context.resourcePath"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
  xray_tracing_enabled = true
}

