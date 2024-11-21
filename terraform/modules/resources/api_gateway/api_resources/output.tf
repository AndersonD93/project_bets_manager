output "url_invoke_api" {
  description = "URL to invoke the API pointing to the stage"
  value       = { for key, api in aws_api_gateway_deployment.api_deployment_put_bets : key => api.invoke_url }
}