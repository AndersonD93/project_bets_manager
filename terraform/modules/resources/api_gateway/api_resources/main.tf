resource "aws_api_gateway_request_validator" "request_validator" {
  for_each                    = var.api_resources
  name                        = "validator_${each.value.resource_id}_${each.value.http_method}"
  rest_api_id                 = var.api_id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "api_method" {
  for_each             = var.api_resources
  rest_api_id          = var.api_id
  resource_id          = each.value.resource_id
  http_method          = each.value.http_method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorizer_id != null ? each.value.authorizer_id : null
  request_validator_id = aws_api_gateway_request_validator.request_validator[each.key].id
}

resource "aws_api_gateway_integration" "api_integration" {
  for_each                = var.api_resources
  rest_api_id             = var.api_id
  resource_id             = each.value.resource_id
  http_method             = aws_api_gateway_method.api_method[each.key].http_method
  integration_http_method = each.value.http_method
  type                    = each.value.type_integration
  request_templates       = each.value.request_templates
  passthrough_behavior    = each.value.passthrough_behavior
  uri                     = each.value.uri != null ? "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${each.value.uri}/invocations" : null 
}

resource "aws_api_gateway_method_response" "api_response" {
  for_each    = var.api_resources
  rest_api_id = var.api_id
  resource_id = each.value.resource_id
  http_method = aws_api_gateway_method.api_method[each.key].http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = each.value.response_models
  depends_on = [
    aws_api_gateway_integration.api_integration
  ]
}

resource "aws_api_gateway_integration_response" "api_integration_response" {
  for_each    = var.api_resources
  rest_api_id  = var.api_id
  resource_id  = each.value.resource_id
  http_method  = aws_api_gateway_method.api_method[each.key].http_method
  status_code  = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.api_integration,
    aws_api_gateway_method_response.api_response
  ]
}

resource "aws_api_gateway_deployment" "api_deployment_put_bets" {
  for_each    = var.api_resources
  rest_api_id = var.api_id
  stage_name  = each.value.stage_name

  depends_on = [
    aws_api_gateway_integration.api_integration
  ]
}