resource "aws_cognito_user_pool" "bets_user_pool" {
  name = "bets-user-pool"
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_group" "admin_group" {
  user_pool_id = aws_cognito_user_pool.bets_user_pool.id
  name         = "admin"
  description  = "Grupo para administradores"
}

resource "aws_cognito_user_group" "general_group" {
  user_pool_id = aws_cognito_user_pool.bets_user_pool.id
  name         = "general"
  description  = "Grupo para usuarios generales"
  #role_arn = ""
}

resource "aws_cognito_user_pool_client" "app_bets_manager" {
  name         = "app-bets-manager"
  user_pool_id = aws_cognito_user_pool.bets_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  generate_secret               = false
}

resource "aws_cognito_identity_pool" "bets_identity_pool" {
  identity_pool_name               = "bets-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id       = aws_cognito_user_pool_client.app_bets_manager.id
    provider_name   = aws_cognito_user_pool.bets_user_pool.endpoint
    server_side_token_check = true
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.bets_identity_pool.id

  roles = {
    authenticated = aws_iam_role.general_role.arn #Rol por defecto
  }

  role_mapping {
    identity_provider = "${aws_cognito_user_pool.bets_user_pool.endpoint}:${aws_cognito_user_pool_client.app_bets_manager.id}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type = "Rules"
  mapping_rule {
    claim      = "cognito:groups"
    match_type = "Equals"
    value      = "admin"
    role_arn   = aws_iam_role.admin_role.arn
      }
  mapping_rule {
      claim      = "cognito:groups"
      match_type = "Equals"
      value      = "general"
      role_arn   = aws_iam_role.general_role.arn
    }  
  }    
}



