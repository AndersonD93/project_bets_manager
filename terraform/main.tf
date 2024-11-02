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

#LAMBDAS
module "update_results" {
  source = "./modules/resources/lambda"
  lambda_name           = "update_results"
  lambda_zip            = "${path.module}/templates/lambdas_code/update_result1.zip"
  handler               = "update_result.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "results_table" = module.results_table.dynamo_table_name
    "matches_table" = module.matches_table.dynamo_table_name
  }
}

module "create_matches_for_futbol_data" {
  source = "./modules/resources/lambda"
  lambda_name           = "create_matches_for_futbol_data"
  lambda_zip            = "${path.module}/templates/lambdas_code/create_matches_for_futbol_data.zip"
  handler               = "create_matches_for_futbol_data.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "matches_table" = module.matches_table.dynamo_table_name
  }
}
module "get_matches" {
  source = "./modules/resources/lambda"
  lambda_name           = "get_matches"
  lambda_zip            = "${path.module}/templates/lambdas_code/get_matches.zip"
  handler               = "get_matches.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "matches_table" = module.matches_table.dynamo_table_name
  }
}

module "recalculate_score" {
  source = "./modules/resources/lambda"
  lambda_name           = "recalculate_score"
  lambda_zip            = "${path.module}/templates/lambdas_code/recalculate_score.zip"
  handler               = "recalculate_score.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "bets_table" = module.bets_users_table.dynamo_table_name
    "results_table" = module.results_table.dynamo_table_name
    "score_table" = module.score_user_table.dynamo_table_name
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream_trigger" {
  event_source_arn  = module.results_table.dynamo_table_stream_arn
  function_name     = module.recalculate_score.lambda_arn
  enabled           = true
  batch_size        = 100
  starting_position = "LATEST"
}

module "put_bets" {
  source = "./modules/resources/lambda"
  lambda_name           = "put_bets"
  lambda_zip            = "${path.module}/templates/lambdas_code/put_bets.zip"
  handler               = "put_bets.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "bets_users_table" = module.bets_users_table.dynamo_table_name
  }
}

module "get_scores" {
  source = "./modules/resources/lambda"
  lambda_name           = "get_scores"
  lambda_zip            = "${path.module}/templates/lambdas_code/get_scores.zip"
  handler               = "get_scores.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "score_user_table" = module.score_user_table.dynamo_table_name
  }
}

module "get_secret" {
  source = "./modules/resources/lambda"
  lambda_name           = "get_secret"
  lambda_zip            = "${path.module}/templates/lambdas_code/get_secret.zip"
  handler               = "get_secret.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "secret_name" = "project/appConfig"
  }
}

module "manage_matches" {
  source = "./modules/resources/lambda"
  lambda_name           = "manage_matches"
  lambda_zip            = "${path.module}/templates/lambdas_code/manage_matches.zip"
  handler               = "manage_matches.lambda_handler"
  runtime               = "python3.9"
  source_arn            = "${aws_api_gateway_rest_api.api_bets_manager.execution_arn}/*/*"
  environment_variables = {
    "matches_table" = module.matches_table.dynamo_table_name
  }
}

#DYNAMO TABLE
module "bets_users_table" {
  source             = "./modules/resources/dynamo_table"
  table_name         = "bets_users"
  hash_key           = "user_id"
  range_key          = "match_id"

  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "match_id"
      type = "S"
    }
  ]

  global_secondary_index = {
    name            = "MatchIdIndex"
    hash_key        = "match_id"
    projection_type = "ALL"
  }

  roles_lambda_principals = [ module.update_results.lambda_arn_role ]

  tags = {
    Project = var.project
  }
}

module "matches_table" {
  source             = "./modules/resources/dynamo_table"
  table_name         = "matches_table"
  hash_key           = "match_id"
  range_key          = "status"

  attributes = [
    {
      name = "match_id"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    }
  ]

  roles_lambda_principals = [ module.update_results.lambda_arn_role , module.create_matches_for_futbol_data.lambda_arn_role, module.get_matches.lambda_arn_role ]

  tags = {
    Project = var.project
  }
}

module "results_table" {
  source             = "./modules/resources/dynamo_table"
  table_name         = "results_table"
  hash_key           = "match_id"
  range_key          = "extact_score"

  attributes = [
    {
      name = "match_id"
      type = "S"
    },
    {
      name = "extact_score"
      type = "S"
    }
  ]
  stream_enabled    = true
  stream_view_type  = "NEW_AND_OLD_IMAGES"

  roles_lambda_principals = [ module.update_results.lambda_arn_role ]

  tags = {
    Project = var.project
  }
}

module "score_user_table" {
  source             = "./modules/resources/dynamo_table"
  table_name         = "score_user"
  hash_key           = "user_id"
  range_key          = "total_score"

  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "total_score"
      type = "N"
    }
  ]

  roles_lambda_principals = [ module.update_results.lambda_arn_role ]

  tags = {
    Project = var.project
  }
}
#API GATEWAY

module "api_bets_manager"{   
  source            = "./modules/resources/api_gateway"
  name_api          = "api_bets_manager_moduls"
  description_api   = "api para gestionar peticiones para backends logica de aplicación"
  type_endpoint     = "REGIONAL"
}

module "api_resource_put_bets"{
  source                 = "./modules/resources/api_gateway/api_resources"
  api_id                 = module.api_bets_manager.api_id
  api_root_resource_id   = module.api_bets_manager.api_root_resource_id
  path_part              = "put_bets"
  http_method            = "OPTIONS"
  authorization          = "NONE"
  type_integration       = "MOCK"
  request_templates      = {
    "application/json" = "{\"statusCode\": 200}"
  }
  passthrough_behavior   = "WHEN_NO_MATCH"
  response_models        = {
    "application/json" = "Empty"
  }
  stage_name             = "prod"
}

resource "aws_api_gateway_rest_api" "api_bets_manager" {
  name        = "api_bets_manager_IAC"
  description = "API for bets manager"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                    = "CognitoAuthorizer"
  rest_api_id             = aws_api_gateway_rest_api.api_bets_manager.id
  identity_source         = "method.request.header.Authorization"
  type                    = "COGNITO_USER_POOLS"
  provider_arns           = ["arn:aws:cognito-idp:us-east-1:122610499801:userpool/us-east-1_TpdDqGK9s"]
  #provider_arns           = [aws_cognito_user_pool.my_user_pool.arn]
}

resource "aws_api_gateway_resource" "put_bets" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  parent_id   = aws_api_gateway_rest_api.api_bets_manager.root_resource_id
  path_part   = "put_bets"
}

resource "aws_api_gateway_method" "bets_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id   = aws_api_gateway_resource.put_bets.id
  http_method   = "OPTIONS"
  authorization = "NONE"
  
}

resource "aws_api_gateway_integration" "bets_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id             = aws_api_gateway_resource.put_bets.id
  http_method             = aws_api_gateway_method.bets_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "bets_options_response" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id = aws_api_gateway_resource.put_bets.id
  http_method = aws_api_gateway_method.bets_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "bets_options_integration_response" {
  rest_api_id  = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id  = aws_api_gateway_resource.put_bets.id
  http_method  = aws_api_gateway_method.bets_options.http_method
  status_code  = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.bets_options_integration
  ]
}

# Crear el método POST en /bets y asignar el autorizador Cognito
resource "aws_api_gateway_method" "bets_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id   = aws_api_gateway_resource.put_bets.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_integration" "bets_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id             = aws_api_gateway_resource.put_bets.id
  http_method             = aws_api_gateway_method.bets_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.put_bets.lambda_arn}/invocations"
}

resource "aws_api_gateway_method_response" "bets_put_response" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id = aws_api_gateway_resource.put_bets.id
  http_method = aws_api_gateway_method.bets_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "bets_put_integration_response" {
  rest_api_id  = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id  = aws_api_gateway_resource.put_bets.id
  http_method  = aws_api_gateway_method.bets_post.http_method
  status_code  = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.bets_post_integration
  ]
}

resource "aws_api_gateway_deployment" "api_deployment_put_bets" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.bets_post_integration,
    aws_api_gateway_integration.bets_options_integration,
  ]
}

# Crear el método Options en /get_secret 

resource "aws_api_gateway_resource" "get_secret" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  parent_id   = aws_api_gateway_rest_api.api_bets_manager.root_resource_id
  path_part   = "get_secret"
}

resource "aws_api_gateway_method" "get_secret_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id   = aws_api_gateway_resource.get_secret.id
  http_method   = "OPTIONS"
  authorization = "NONE"
  
}

resource "aws_api_gateway_integration" "get_secret_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id             = aws_api_gateway_resource.get_secret.id
  http_method             = aws_api_gateway_method.get_secret_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "get_secret_response" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id = aws_api_gateway_resource.get_secret.id
  http_method = aws_api_gateway_method.get_secret_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "get_secret_options_integration_response" {
  rest_api_id  = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id  = aws_api_gateway_resource.get_secret.id
  http_method  = aws_api_gateway_method.get_secret_options.http_method
  status_code  = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.bets_options_integration
  ]
}

# Crear el método GET en /get_secret 

resource "aws_api_gateway_method" "get_secret_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id   = aws_api_gateway_resource.get_secret.id
  http_method   = "GET"
  authorization = "NONE"
  
}

resource "aws_api_gateway_integration" "get_secret_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id             = aws_api_gateway_resource.get_secret.id
  http_method             = aws_api_gateway_method.get_secret_get.http_method
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.get_secret.lambda_arn}/invocations"

  depends_on = [
    aws_api_gateway_method.get_secret_get
  ]
}

resource "aws_api_gateway_method_response" "get_secret_get_response" {
  rest_api_id = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id = aws_api_gateway_resource.get_secret.id
  http_method = aws_api_gateway_method.get_secret_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "get_secret_get_integration_response" {
  rest_api_id  = aws_api_gateway_rest_api.api_bets_manager.id
  resource_id  = aws_api_gateway_resource.get_secret.id
  http_method  = aws_api_gateway_method.get_secret_get.http_method
  status_code  = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${module.resources.s3_bucket_website_url}'"
  }

  response_templates = {
    "application/json" = <<EOF
      #set($inputRoot = $input.path('$'))
      {
        "message": "$inputRoot.message",
        "data": $input.json('$')
      }
    EOF
  }

  depends_on = [
    aws_api_gateway_integration.get_secret_get_integration,
    module.get_secret.lambda_permission_api
  ]
}


