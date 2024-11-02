resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.name_api}_IAC"
  description = var.description_api
  endpoint_configuration {
    types = [var.type_endpoint]
  }
}