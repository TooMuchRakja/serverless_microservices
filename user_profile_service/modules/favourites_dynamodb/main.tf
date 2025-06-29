# DYNAMODB TABLE DEFINITION - FOR ADDING FAVOURITES RESTURANTS FROM USERS 

resource "aws_dynamodb_table" "favourites_ddbtable" {
  name           = "${var.stack_name}_favourites_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "restaurant_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "restaurant_id"
    type = "S"
  }
  
  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
    Service     = "Favourites_Table"
  }
}