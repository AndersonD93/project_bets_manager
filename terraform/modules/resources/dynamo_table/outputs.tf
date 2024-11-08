output "dynamo_table_arn" {
  description = "ARNs de todas las tablas DynamoDB"
  value       = {for key, table in aws_dynamodb_table.dynamo_table: key => table.arn}  
}

output "dynamo_table_name" {
  description = "nombres de las tabla DynamoDB"
  value       = {for key, table in aws_dynamodb_table.dynamo_table: key => table.name}
}

output "dynamo_table_stream_arn" {
  description = "ARN del stream de la tabla DynamoDB"
  value       = aws_dynamodb_table.dynamo_table["results_table"].stream_arn
}

