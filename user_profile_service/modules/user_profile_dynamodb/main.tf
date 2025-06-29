resource "aws_dynamodb_table" "user_profile_address_table" {
    name = "user_profile_table"
    hash_key = "user_id"
    range_key = "address_id"
    billing_mode = "PAY_PER_REQUEST"
    attribute {
        name = "user_id"
        type = "S"
    }
    attribute {
        name = "address_id"
        type = "S"
    }
  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
    Service     = "User_Profile_Address_Table"
  }
} 