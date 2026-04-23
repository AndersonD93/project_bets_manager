output "arn_api_gateway" {
  value = module.api_bets_manager.api_arn
}

output "arn_role_lambda" {
  value = module.lambdas_backend_api.lambda_role_arns["update_results"]
}

output "arn_dynamo_table_stream" {
  value = module.dynamo_tables_bets_manager.dynamo_table_stream_arn
}

output "dynamo_table_names" {
  value = module.dynamo_tables_bets_manager.list_table_arn_dynamo
}

output "lookup_score_user_table" {
  value = module.dynamo_tables_bets_manager.lookup_score_user_table
}

output "url_invoke_api" {
  value = "${module.api_resource_create_update_results.url_invoke_api["create_matches_football_data_post"]}/get_secret"
}

output "s3_bucket_website_url" {
  value = module.resources.s3_bucket_website_url
}

output "cloudfront_url" {
  description = "URL HTTPS del frontend via CloudFront"
  value       = module.resources.cloudfront_url
}

output "cloudfront_distribution_id" {
  description = "ID distribución CloudFront (útil para invalidaciones)"
  value       = module.resources.cloudfront_distribution_id
}

output "arn_method" {
  value =module.api_resource_get_secret.method_arn
}

output "bets_users_global_index_name" {
  description = "Nombre del índice global de la tabla bets_users"
  value       = module.dynamo_tables_bets_manager.global_secondary_index_names["bets_users_table"]
}

