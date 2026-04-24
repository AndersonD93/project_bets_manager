#API GATEWAY

locals {
  cloudfront_origin = "'https://d3iqu3owmhprm.cloudfront.net'"
}

module "api_bets_manager" {
  source          = "./modules/resources/api_gateway"
  name_api        = "api_bets_manager_moduls"
  description_api = "api para gestionar peticiones para backends logica de aplicación"
  type_endpoint   = "REGIONAL"
  path_part_list  = ["put_bets", "get_secret", "manage_matches", "create-matches-football-data", "update_results", "manage_match_status", "get_results", "get_bets", "champion", "champion-config", "tournament-champion"]
}

resource "aws_api_gateway_authorizer" "cognito_authorizer_module" {
  name            = "CognitoAuthorizerModule"
  rest_api_id     = module.api_bets_manager.api_id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.bets_user_pool.arn]
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
      url_cors_allow       = local.cloudfront_origin
    },
    "put_bets_put" = {
      resource_id      = module.api_bets_manager.api_resource_ids["put_bets"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["put_bets"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
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
      url_cors_allow       = local.cloudfront_origin
    },
    "get_secret_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["get_secret"]
      http_method      = "GET"
      authorization    = "NONE"
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_secret"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
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
      url_cors_allow       = local.cloudfront_origin
    },
    "manage_matches_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["manage_matches"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["manage_matches"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    },
    "manage_matches_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["manage_matches"]
      http_method      = "GET"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_matches"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
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
      url_cors_allow       = local.cloudfront_origin
    },
    "create_matches_football_data_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["create-matches-football-data"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["create_matches_for_futbol_data"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
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
      url_cors_allow       = local.cloudfront_origin
    },
    "update_results_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["update_results"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["update_results"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    },
    "update_results_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["update_results"]
      http_method      = "GET"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_scores"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}

# config.js ya no es necesario — React usa VITE_API_URL en build time

module "api_resource_get_results" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "get_results_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["get_results"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
      url_cors_allow       = local.cloudfront_origin
    },
    "get_results_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["get_results"]
      http_method      = "GET"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_results"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}

module "api_resource_manage_match_status" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "manage_match_status_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["manage_match_status"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
      url_cors_allow       = local.cloudfront_origin
    },
    "manage_match_status_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["manage_match_status"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["manage_match_status"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}

module "api_resource_get_bets" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "get_bets_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["get_bets"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
      url_cors_allow       = local.cloudfront_origin
    },
    "get_bets_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["get_bets"]
      http_method      = "GET"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_bets"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}

module "api_resource_champion" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "champion_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["champion"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
      url_cors_allow       = local.cloudfront_origin
    },
    "champion_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["champion"]
      http_method      = "GET"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_champion"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    },
    "champion_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["champion"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["put_champion"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}

module "api_resource_champion_config" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "champion_config_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["champion-config"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
      url_cors_allow       = local.cloudfront_origin
    },
    "champion_config_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["champion-config"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["manage_champion_config"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}

module "api_resource_tournament_champion" {
  source               = "./modules/resources/api_gateway/api_resources"
  api_id               = module.api_bets_manager.api_id
  api_root_resource_id = module.api_bets_manager.api_root_resource_id

  api_resources = {
    "tournament_champion_options" = {
      resource_id          = module.api_bets_manager.api_resource_ids["tournament-champion"]
      http_method          = "OPTIONS"
      authorization        = "NONE"
      type_integration     = "MOCK"
      request_templates    = { "application/json" = "{\"statusCode\": 200}" }
      passthrough_behavior = "WHEN_NO_MATCH"
      response_models      = { "application/json" = "Empty" }
      stage_name           = "prd"
      url_cors_allow       = local.cloudfront_origin
    },
    "tournament_champion_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["tournament-champion"]
      http_method      = "GET"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_tournament_champion"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    },
    "tournament_champion_post" = {
      resource_id      = module.api_bets_manager.api_resource_ids["tournament-champion"]
      http_method      = "POST"
      authorization    = "COGNITO_USER_POOLS"
      authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer_module.id
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["set_tournament_champion"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = local.cloudfront_origin
    }
  }
}
