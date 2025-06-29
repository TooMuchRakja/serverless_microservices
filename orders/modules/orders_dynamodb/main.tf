# tutaj zbuduję tabelę dynamo db która będzie przechowywać zamówienia klientów 

resource "aws_dynamodb_table" "orders_table" {
  name         = "${var.stack_name}_orders_table" # TO BEDZIE NAZWA TABELI TERRAFORM W AWS 
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "userId" # PARTITION KEY
  range_key    = "orderId"  #SORT KEY 

# PONIZEJ DEFINIUJE KAZDY ATRYBUT TABELI KTORY JEST POWYZSZYM KLUCZEM - CZYLI DWA ATRYBUTY 
  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "orderId"
    type = "S"
  }

  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
    Service     = "Orders_Table"
  }
}


# tutaj zbuduję tabelę dynamo db która będzie przechowywać zamówienia klientów 

resource "aws_dynamodb_table" "idempotence_table" {
  name         = "${var.stack_name}_idempotence_table" # TO BEDZIE NAZWA TABELI TERRAFORM W AWS 
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "id" # PARTITION KEY


# PONIZEJ DEFINIUJE KAZDY ATRYBUT TABELI KTORY JEST POWYZSZYM KLUCZEM - CZYLI DWA ATRYBUTY 
  attribute {
    name = "id"
    type = "S"
  }

  ttl {
  attribute_name = "expiration" # ta nazwa atrybutu będzie wystepować w funkcjach 
  enabled        = true
}

  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
    Service     = "Idempotence_Table"
  }
}