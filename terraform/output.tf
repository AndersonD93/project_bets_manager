output "arn_api_gateway" {
  value = module.api_bets_manager.api_arn
}

output "arn_role_lambda"{
  value = module.lambdas_backend_api.lambda_role_arns["update_results"]
}

