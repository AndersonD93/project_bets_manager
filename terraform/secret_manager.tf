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
  secret_map = {
    UrlApiManageMatches                   = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/manage_matches",
    UrlApiUpdateResults                   = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/update_results",
    UrlApiPutBets                         = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/put_bets",
    UrlApiCreateMatchesForAPiFootballData = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/create-matches-football-data",
    UrlApiManageMatchStatus               = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/manage_match_status",
    UrlApiGetResults                      = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/get_results",
    UrlApiGetBets                         = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/get_bets",
    UrlApiChampion                        = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/champion",
    UrlApiChampionConfig                  = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/champion-config",
    X-Auth-Token                          = jsondecode(data.aws_secretsmanager_secret_version.existing_secret_version.secret_string)["X-Auth-Token"],
    UserPoolId                            = aws_cognito_user_pool.bets_user_pool.id,
    ClientId                              = aws_cognito_user_pool_client.app_bets_manager.id
  }
}

resource "aws_secretsmanager_secret_version" "new_secret_version" {
  secret_id     = aws_secretsmanager_secret.secrets_project.id
  secret_string = jsonencode(local.secret_map)
}
