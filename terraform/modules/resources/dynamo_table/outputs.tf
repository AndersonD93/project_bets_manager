output "dynamo_table_arn" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.dynamo_table.arn
}

output "dynamo_table_name" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.dynamo_table.name
}

output "dynamo_table_stream_arn" {
  description = "ARN del stream de la tabla DynamoDB"
  value       = aws_dynamodb_table.dynamo_table.stream_arn
}

