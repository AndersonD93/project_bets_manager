output "lambda_arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_arn_role" {
  description = "ARN del rol de la función Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_permission_api" {
  description = "ARN del rol de la función Lambda"
  value       = aws_lambda_permission.lambda_permission
}