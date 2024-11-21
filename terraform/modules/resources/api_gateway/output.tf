output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "api_arn" {
  value = aws_api_gateway_rest_api.api.arn
}

output "api_root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}

output "api_resource_ids" {
  value       = { for key, resource in aws_api_gateway_resource.api_resource : key => resource.id }
  description = "Mapeo de cada path part con su id de recurso en API Gateway"
}
