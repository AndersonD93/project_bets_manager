
variable "s3_list_name" {
  description = "Lista de nombres de buckets S3"
  type        = map(string)
}

variable "dynamo_tables_list_name" {
  description = "Lista de nombres de tablas de DynamoDB"
  type        = map(string)
}

variable "project" {
  default = "bets-manager"
}
