output "url_invoke_api" {
  description = "URL to invoke the API pointing to the stage"
  value       = { for key, api in aws_api_gateway_deployment.api_deployment_put_bets : key => api.invoke_url }
}

output "method_arn" {
  value = { for key, api in aws_api_gateway_method.api_method : key => 
    "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api_id}/*/${api.http_method}/*" }
}