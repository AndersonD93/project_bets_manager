output "api_id" {   
    value = aws_api_gateway_rest_api.api.id
}

output "api_arn" {
    value = aws_api_gateway_rest_api.api.arn
}

output "api_root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}