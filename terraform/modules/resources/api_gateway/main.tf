resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.name_api}_IAC"
  description = var.description_api
  endpoint_configuration {
    types = [var.type_endpoint]
  }
}

resource "aws_api_gateway_resource" "api_resource" {
  for_each    = var.path_part_list
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value
}