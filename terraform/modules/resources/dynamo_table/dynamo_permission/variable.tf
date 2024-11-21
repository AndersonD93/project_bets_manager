variable "mapping_dynamo_permission" {
  description = "Mapa de asociación de rol a permiso de recurso dynamo"

  type = map(object({
    table_arn               = string,
    roles_lambda_principals = list(string)
    })
  )
}