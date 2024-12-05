#API GATEWAY

module "api_bets_manager" {
  source          = "./modules/resources/api_gateway"
  name_api        = "api_bets_manager_moduls"
  description_api = "api para gestionar peticiones para backends logica de aplicación"
  type_endpoint   = "REGIONAL"
  path_part_list  = ["put_bets", "get_secret", "manage_matches", "create-matches-football-data", "update_results"]
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
      url_cors_allow       = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow       = "'${module.resources.s3_bucket_website_url}'"
    },
    "get_secret_get" = {
      resource_id      = module.api_bets_manager.api_resource_ids["get_secret"]
      http_method      = "GET"
      authorization    = "NONE"
      type_integration = "AWS_PROXY"
      uri              = module.lambdas_backend_api.invoke_arn["get_secret"]
      response_models  = { "application/json" = "Empty" }
      stage_name       = "prd"
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow       = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow       = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow       = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
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
      url_cors_allow   = "'${module.resources.s3_bucket_website_url}'"
    }
  }
}

resource "local_file" "config_js" {
  filename = "${path.module}/templates/js/config.js"
  content  = templatefile("${path.module}/templates/js/config.js", {
    url_invoke_api = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/get_secret"
  })
}