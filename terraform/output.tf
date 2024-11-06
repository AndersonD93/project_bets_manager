output "arn_api_gateway" {
  value = module.api_bets_manager.api_arn
}

output "arn_lambda_get_secret" {
  value = module.get_secret.lambda_arn
}
