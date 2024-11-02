resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = var.api_id
  parent_id   = var.api_root_resource_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = var.http_method
  authorization = var.authorization 
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = var.http_method
  type                    = var.type_integration
  request_templates       = local.request_templates
  passthrough_behavior    = length(var.request_templates) > 0 ? var.passthrough_behavior : null  

}

resource "aws_api_gateway_method_response" "api_response" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = local.response_models
}

resource "aws_api_gateway_integration_response" "api_integration_response" {
  rest_api_id  = var.api_id
  resource_id  = aws_api_gateway_resource.api_resource.id
  http_method  = aws_api_gateway_method.api_method.http_method
  status_code  = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.api_integration
  ]
}

resource "aws_api_gateway_deployment" "api_deployment_put_bets" {
  rest_api_id = var.api_id
  stage_name  = var.stage_name

  depends_on = [
    aws_api_gateway_integration.api_integration
  ]
}