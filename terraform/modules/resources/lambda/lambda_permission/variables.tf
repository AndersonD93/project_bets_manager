variable "mapping_lambda_permission_api" {
  description = "Mapa de asociación de rol a permiso de recurso dynamo"

  type = map(object({
    source_arn                   = string,
    lambda_name                  = string,
    principal                    = string
    })
  )
}