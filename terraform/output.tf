output "arn_api_gateway" {
  value = module.api_bets_manager.api_arn
}

output "arn_role_lambda"{
  value = module.lambdas_backend_api.lambda_role_arns["update_results"]
}

output "arn_dynamo_table_stream" {
  value = module.dynamo_tables_bets_manager.dynamo_table_stream_arn
}

