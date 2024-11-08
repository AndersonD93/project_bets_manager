# Run init/plan/apply with "backend" commented-out (ueses local backend) to provision Resources (Bucket, Table)
# Then uncomment "backend" and run init, apply after Resources have been created (uses AWS)


terraform {
  backend "s3" {
    bucket         = "cc-tf-state-backend-ci-cd-ajduran"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true  
    dynamodb_table = "terraform-state-locking-ajduran2"
  }
}

provider "aws" {
  region = "us-east-1"
}


module "resources" {
  source = "./modules/resources"

  # Resoruces Input Vars
  s3_list_name = local.s3_list_name
  dynamo_tables_list_name = local.dynamo_tables_list_name
}


module "tf-state" {
  source      = "./modules/tf-state"
  bucket_name = "cc-tf-state-backend-ci-cd-ajduran"
}

#API GATEWAY

module "api_bets_manager"{   
  source            = "./modules/resources/api_gateway"
  name_api          = "api_bets_manager_moduls"
  description_api   = "api para gestionar peticiones para backends logica de aplicación"
  type_endpoint     = "REGIONAL"
  path_part_list    = ["put_bets","get_secret","manage_matches","create-matches-football-data","update_results"] 
}

resource "aws_api_gateway_authorizer" "cognito_authorizer_module" {
  name                    = "CognitoAuthorizerModule"
  rest_api_id             = module.api_bets_manager.api_id
  identity_source         = "method.request.header.Authorization"
  type                    = "COGNITO_USER_POOLS"
  provider_arns           = ["arn:aws:cognito-idp:us-east-1:122610499801:userpool/us-east-1_TpdDqGK9s"]
  #provider_arns           = [aws_cognito_user_pool.my_user_pool.arn]
}

module "api_resource_put_bets" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "put_bets_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["put_bets"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "put_bets_put" = {
      resource_id          = module.api_bets_manager.api_resource_ids["put_bets"]
      http_method          = "POST"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["put_bets"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    }
  }
}

module "api_resource_get_secret" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "get_secret_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["get_secret"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "get_secret_get" = {
      resource_id          = module.api_bets_manager.api_resource_ids["get_secret"]
      http_method          = "GET"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["get_secret"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    }
  }
}

module "api_resource_manage_matches" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "manage_matches_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["manage_matches"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "manage_matches_post" = {
      resource_id          = module.api_bets_manager.api_resource_ids["manage_matches"]
      http_method          = "POST"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["manage_matches"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "manage_matches_get" = {
      resource_id          = module.api_bets_manager.api_resource_ids["manage_matches"]
      http_method          = "GET"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["manage_matches"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    }
  }
}

module "api_resource_create_update_results" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "create_matches_football_data_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["create-matches-football-data"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "create_matches_football_data_post" = {
      resource_id          = module.api_bets_manager.api_resource_ids["create-matches-football-data"]
      http_method          = "POST"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["create_matches_for_futbol_data"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    }
  }
}

module "api_resource_update_results" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "update_results_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["update_results"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "update_results_post" = {
      resource_id          = module.api_bets_manager.api_resource_ids["update_results"]
      http_method          = "POST"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["update_results"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    },
    "update_results_get" = {
      resource_id          = module.api_bets_manager.api_resource_ids["update_results"]
      http_method          = "GET"
      authorization        = "COGNITO_USER_POOLS"
      authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration     = "AWS"
      uri                  = module.lambdas_backend_api.lambda_arns["update_results"]
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
    }
  }
}
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
        #"results_table" = module.dynamo_tables_bets_manager.dynamo_table_name["results_table"]
        #"matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "manage_matches" = {
      lambda_name           = "manage_matches"
      lambda_zip            = "${path.module}/templates/lambdas_code/manage_matches.zip"
      handler               = "manage_matches.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        #"matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    "create_matches_for_futbol_data" = {
      lambda_name           = "create_matches_for_futbol_data"
      lambda_zip            = "${path.module}/templates/lambdas_code/create_matches_for_futbol_data.zip"
      handler               = "create_matches_for_futbol_data.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        #"matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
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
        #"bets_users_table"  = module.dynamo_tables_bets_manager.dynamo_table_name["bets_users_table"]
      }
    },
    recalculate_score = {
      lambda_name           = "recalculate_score"
      lambda_zip            = "${path.module}/templates/lambdas_code/recalculate_score.zip"
      handler               = "recalculate_score.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        #"bets_table"    = module.dynamo_tables_bets_manager.dynamo_table_name["bets_users_table"]
        #"results_table" = module.dynamo_tables_bets_manager.dynamo_table_name["results_table"]
        #"score_table"   = module.dynamo_tables_bets_manager.dynamo_table_name["score_user_table"]
      }
    },
    get_matches = {
      lambda_name           = "get_matches"
      lambda_zip            = "${path.module}/templates/lambdas_code/get_matches.zip"
      handler               = "get_matches.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        #"matches_table" = module.dynamo_tables_bets_manager.dynamo_table_name["matches_table"]
      }
    },
    get_scores = {
      lambda_name           = "get_scores"
      lambda_zip            = "${path.module}/templates/lambdas_code/get_scores.zip"
      handler               = "get_scores.lambda_handler"
      runtime               = "python3.12"
      source_arn            = "${module.api_bets_manager.api_arn}/*/*"
      environment_variables = {
        #"score_user_table"  = module.dynamo_tables_bets_manager.dynamo_table_name["score_user_table"]
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


#DYNAMO TABLE
module "dynamo_tables_bets_manager" {
  source = "./modules/resources/dynamo_table"

  dynamo_tables = {
    score_user_table = {
      table_name         = "score_user"
      hash_key           = "user_id"
      range_key          = "total_score"
      attributes         = [
        { name = "user_id", type = "S" },
        { name = "total_score", type = "N" }
      ]
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"]]
      tags                    = { Project = var.project }
    },
    results_table = {
      table_name         = "results_table"
      hash_key           = "match_id"
      range_key          = "extact_score"
      attributes         = [
        { name = "match_id", type = "S" },
        { name = "extact_score", type = "S" }
      ]
      stream_enabled     = true
      stream_view_type   = "NEW_AND_OLD_IMAGES"
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"]]
      tags                    = { Project = var.project }
    },
    matches_table = {
      table_name         = "matches_table"
      hash_key           = "match_id"
      range_key          = "status"
      attributes         = [
        { name = "match_id", type = "S" },
        { name = "status", type = "S" }
      ]
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"] , module.lambdas_backend_api.lambda_role_arns["create_matches_for_futbol_data"] , module.lambdas_backend_api.lambda_role_arns["get_matches"]]
      tags                    = { Project = var.project }
    },
    bets_users_table = {
      table_name         = "bets_users"
      hash_key           = "user_id"
      range_key          = "match_id"
      attributes         = [
        { name = "user_id", type = "S" },
        { name = "match_id", type = "S" }
      ]
      global_secondary_index = {
        name            = "MatchIdIndex"
        hash_key        = "match_id"
        projection_type = "ALL"
      }
      roles_lambda_principals = [module.lambdas_backend_api.lambda_role_arns["update_results"]]
      tags                    = { Project = var.project }
    }
  }
}
