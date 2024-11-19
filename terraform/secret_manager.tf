data "aws_secretsmanager_secret" "secret_public_api" {
  name = "project/footbal-data"
}

data "aws_secretsmanager_secret_version" "existing_secret_version" {
  secret_id = data.aws_secretsmanager_secret.secret_public_api.id
}

resource "aws_secretsmanager_secret" "secrets_project" {
  name        = "project/app-bets-manager"
  description = "Secreto para administración de app."
}

locals {
  secret_map ={
    UrlApiManageMatches                   = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/manage_matches",
    UrlApiUpdateResults                   = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/update_results",
    UrlApiPutBets                         = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/put_bets",
    UrlApiCreateMatchesForAPiFootballData = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/create-matches-football-data",
    X-Auth-Token                          = jsondecode(data.aws_secretsmanager_secret_version.existing_secret_version.secret_string)["X-Auth-Token"] 
  }
}

resource "aws_secretsmanager_secret_version" "new_secret_version" {
  secret_id     = aws_secretsmanager_secret.secrets_project.id
  secret_string = jsonencode(local.secret_map)
}
