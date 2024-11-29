#DYNAMO TABLE
module "dynamo_tables_bets_manager" {
  source = "./modules/resources/dynamo_table"

  dynamo_tables = {
    score_user_table = {
      table_name = "score_user"
      hash_key   = "user_id"
      range_key  = "total_score"
      attributes = [
        { name = "user_id", type = "S" },
        { name = "total_score", type = "N" }
      ]
      tags = { Project = var.project }
    },
    results_table = {
      table_name = "results_table"
      hash_key   = "match_id"
      range_key  = "exact_score"
      attributes = [
        { name = "match_id", type = "S" },
        { name = "exact_score", type = "S" }
      ]
      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"
      tags             = { Project = var.project }
    },
    matches_table = {
      table_name = "matches_table"
      hash_key   = "match_id"
      attributes = [
        { name = "match_id", type = "S" }
      ]
      tags = { Project = var.project }
    },
    bets_users_table = {
      table_name = "bets_users"
      hash_key   = "user_id"
      range_key  = "match_id"
      attributes = [
        { name = "user_id", type = "S" },
        { name = "match_id", type = "S" }
      ]
      global_secondary_index = {
        name            = "MatchIdIndex"
        hash_key        = "match_id"
        projection_type = "ALL"
      }
      tags = { Project = var.project }
    }
  }
}

#DYNAMO PERMISSION
module "table_permission" {
  source = "./modules/resources/dynamo_table/dynamo_permission"
  mapping_dynamo_permission = {
    score_user_table = {
      table_arn               = module.dynamo_tables_bets_manager.dynamo_table_arn["score_user_table"]
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"]]
    },
    results_table = {
      table_arn               = module.dynamo_tables_bets_manager.dynamo_table_arn["results_table"]
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"]]
    },
    matches_table = {
      table_arn               = module.dynamo_tables_bets_manager.dynamo_table_arn["matches_table"]
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"], module.lambdas_backend_api.lambda_role_arns["create_matches_for_futbol_data"], module.lambdas_backend_api.lambda_role_arns["get_matches"]]
    },
    bets_users_table = {
      table_arn               = module.dynamo_tables_bets_manager.dynamo_table_arn["bets_users_table"]
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"]]
    }
  }
}