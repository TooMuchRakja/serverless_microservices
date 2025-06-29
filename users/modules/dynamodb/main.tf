module "dynamodb_table" {
  source       = "terraform-aws-modules/dynamodb-table/aws"
  name         =  var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userid" # PARTITION KEY - OBOWIAZKOWY - NIE MOZNA GO EDYTOWAC 

  attributes = [
    {
      name = "userid"
      type   = "S"
    }
  ]
  tags = {
    stack_name  = "${var.stack_name}"
    Environment = "${var.environment}"
    Service     = "Users_Table"
  }
}
