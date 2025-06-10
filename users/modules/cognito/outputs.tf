output "UserPool" {
  value = aws_cognito_user_pool.user_pool.id
}

output "UserPoolClient" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "UserPoolAdminGroupName" {
  value = var.user_pool_admin_group_name
}

output "CognitoLoginURL" {
  value = "https://${var.cognito_user_pool_domain}.auth.${var.region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.user_pool_client.id}&response_type=code&redirect_uri=http://localhost"
}

output "CognitoAuthCommand" {
  value = "aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --client-id ${aws_cognito_user_pool_client.user_pool_client.id} --region ${var.region} --auth-parameters USERNAME=<user@example.com>,PASSWORD=<password>"
}