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
    Environment = "Prod"
    Service     = "Orders"
  }
}