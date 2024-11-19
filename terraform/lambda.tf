#LAMBDAS
module "lambdas_backend_api" {
  source     = "./modules/resources/lambda"
  lambda_map = {
    "update_results" = {
      lambda_name           = "update_results"
      lambda_zip            = "${path.module}/templates/lambdas_code/update_result.zip"
      handler               = "update_result.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "results_table" = module.dynamo_tables_bets_manager.dynamo_table_name["results_table"]
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "manage_matches" = {
      lambda_name           = "manage_matches"
      lambda_zip            = "${path.module}/templates/lambdas_code/manage_matches.zip"
      handler               = "manage_matches.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "create_matches_for_futbol_data" = {
      lambda_name           = "create_matches_for_futbol_data"
      lambda_zip            = "${path.module}/templates/lambdas_code/create_matches_for_futbol_data.zip"
      handler               = "create_matches_for_futbol_data.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "get_secret" = {
      lambda_name           = "get_secret"
      lambda_zip            = "${path.module}/templates/lambdas_code/get_secret.zip"
      handler               = "get_secret.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "secret_name" = "project/appConfig"
      }
    },
    "put_bets" = {
      lambda_name           = "put_bets"
      lambda_zip            = "${path.module}/templates/lambdas_code/put_bets.zip"
      handler               = "put_bets.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "bets_users_table"  = module.dynamo_tables_bets_manager.dynamo_table_name["bets_users_table"]
      }
    },
    recalculate_score = {
      lambda_name           = "recalculate_score"
      lambda_zip            = "${path.module}/templates/lambdas_code/recalculate_score.zip"
      handler               = "recalculate_score.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "bets_table"    = module.dynamo_tables_bets_manager.dynamo_table_name["bets_users_table"]
        "results_table" = module.dynamo_tables_bets_manager.dynamo_table_name["results_table"]
        "score_table"   = module.dynamo_tables_bets_manager.dynamo_table_name["score_user_table"]
      }
    },
    get_matches = {
      lambda_name           = "get_matches"
      lambda_zip            = "${path.module}/templates/lambdas_code/get_matches.zip"
      handler               = "get_matches.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    get_scores = {
      lambda_name           = "get_scores"
      lambda_zip            = "${path.module}/templates/lambdas_code/get_scores.zip"
      handler               = "get_scores.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        "score_user_table"  = module.dynamo_tables_bets_manager.dynamo_table_name["score_user_table"]
      }
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
