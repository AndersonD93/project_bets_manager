#LAMBDAS
module "lambdas_backend_api" {
  source = "./modules/resources/lambda"
  lambda_map = {
    "update_results" = {
      lambda_name = "update_results"
      handler     = "update_results.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "results_table" = module.dynamo_tables_bets_manager.dynamo_table_name["results_table"]
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "manage_matches" = {
      lambda_name = "manage_matches"
      handler     = "manage_matches.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "create_matches_for_futbol_data" = {
      lambda_name = "create_matches_for_futbol_data"
      handler     = "create_matches_for_futbol_data.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
        "secret_name"   = aws_secretsmanager_secret.secrets_project.name
        "region"        = var.region
      }
    },
    "get_secret" = {
      lambda_name = "get_secret"
      handler     = "get_secret.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "secret_name" = aws_secretsmanager_secret.secrets_project.name
      }
    },
    "put_bets" = {
      lambda_name = "put_bets"
      handler     = "put_bets.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "bets_users_table" = module.dynamo_tables_bets_manager.dynamo_table_name["bets_users_table"]
      }
    },
    recalculate_score = {
      lambda_name = "recalculate_score"
      handler     = "recalculate_score.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "bets_table"                   = module.dynamo_tables_bets_manager.dynamo_table_name["bets_users_table"]
        "results_table"                = module.dynamo_tables_bets_manager.dynamo_table_name["results_table"]
        "score_table"                  = module.dynamo_tables_bets_manager.dynamo_table_name["score_user_table"]
        "bets_users_global_index_name" = module.dynamo_tables_bets_manager.global_secondary_index_names["bets_users_table"]
      }
    },
    get_matches = {
      lambda_name = "get_matches"
      handler     = "get_matches.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    get_scores = {
      lambda_name = "get_scores"
      handler     = "get_scores.lambda_handler"
      runtime     = "python3.12"
      environment_variables = {
        "score_user_table" = module.dynamo_tables_bets_manager.dynamo_table_name["score_user_table"]
      }
    }
  }
}

module "lambda_permission_api" {
  source = "./modules/resources/lambda/lambda_permission"
  mapping_lambda_permission_api = {
    "update_results" = {
      lambda_name = module.lambdas_backend_api.lambda_name["update_results"]
      source_arn  = module.api_resource_update_results.method_arn["update_results_post"]
      principal   = "apigateway.amazonaws.com"
    },
    "manage_matches" = {
      lambda_name = module.lambdas_backend_api.lambda_name["manage_matches"]
      source_arn  = module.api_resource_manage_matches.method_arn["manage_matches_post"]
      principal   = "apigateway.amazonaws.com"
    },
    "create_matches_for_futbol_data" = {
      lambda_name = module.lambdas_backend_api.lambda_name["create_matches_for_futbol_data"]
      source_arn  = module.api_resource_create_update_results.method_arn["create_matches_football_data_post"]
      principal   = "apigateway.amazonaws.com"
    },
    "get_secret" = {
      lambda_name = module.lambdas_backend_api.lambda_name["get_secret"]
      source_arn  = module.api_resource_get_secret.method_arn["get_secret_get"]
      principal   = "apigateway.amazonaws.com"
    },
    "put_bets" = {
      lambda_name = module.lambdas_backend_api.lambda_name["put_bets"]
      source_arn  = module.api_resource_put_bets.method_arn["put_bets_put"]
      principal   = "apigateway.amazonaws.com"
    },
    get_matches = {
      lambda_name = module.lambdas_backend_api.lambda_name["get_matches"]
      source_arn  = module.api_resource_manage_matches.method_arn["manage_matches_get"]
      principal   = "apigateway.amazonaws.com"
    },
    get_scores = {
      lambda_name = module.lambdas_backend_api.lambda_name["get_scores"]
      source_arn  = module.api_resource_update_results.method_arn["update_results_get"]
      principal   = "apigateway.amazonaws.com"
    }
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream_trigger" {
  event_source_arn  = module.dynamo_tables_bets_manager.dynamo_table_stream_arn
  function_name     = module.lambdas_backend_api.lambda_arns["recalculate_score"]
  enabled           = true
  batch_size        = 100
  starting_position = "LATEST"
}
