output "lambda_arns" {
  description = "ARNs de todas las funciones Lambda"
  value       = { for key, lambda in aws_lambda_function.lambda_function : key => lambda.arn }
}

output "lambda_role_arns" {
  description = "ARNs de todos los roles de las funciones Lambda"
  value       = { for key, role in aws_iam_role.lambda_role : key => role.arn }
}

output "lambda_permissions" {
  description = "Permisos Lambda para API Gateway"
  value       = { for key, perm in aws_lambda_permission.lambda_permission : key => perm }
}
