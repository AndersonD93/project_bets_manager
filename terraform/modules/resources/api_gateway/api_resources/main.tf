resource "aws_api_gateway_method" "api_method" {
  for_each      = var.api_resources
  rest_api_id   = var.api_id
  resource_id   = each.value.resource_id
  http_method   = each.value.http_method
  authorization = each.value.authorization
  authorizer_id = each.value.authorizer_id != null ? each.value.authorizer_id : null
}

resource "aws_api_gateway_integration" "api_integration" {
  for_each                = var.api_resources
  rest_api_id             = var.api_id
  resource_id             = each.value.resource_id
  http_method             = aws_api_gateway_method.api_method[each.key].http_method
  # ✅ MOCK no lleva integration_http_method
  integration_http_method = each.value.type_integration == "MOCK" ? null : "POST"
  type                    = each.value.type_integration
  request_templates       = each.value.request_templates
  passthrough_behavior    = each.value.passthrough_behavior
  uri                     = try(each.value.uri, null)
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
  depends_on      = [aws_api_gateway_integration.api_integration]
}

# ✅ Solo para MOCK (OPTIONS) — AWS_PROXY no necesita integration_response
resource "aws_api_gateway_integration_response" "api_integration_response" {
  for_each    = { for k, v in var.api_resources : k => v if v.type_integration == "MOCK" }
  rest_api_id = var.api_id
  resource_id = each.value.resource_id
  http_method = aws_api_gateway_method.api_method[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = each.value.url_cors_allow
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
  depends_on  = [aws_api_gateway_integration.api_integration]
}

data "aws_caller_identity" "current" {}