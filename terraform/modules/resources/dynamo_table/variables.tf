variable "project" {
  default = "bets-manager"
}

variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Clave hash de la tabla DynamoDB"
  type        = string
}

variable "range_key" {
  description = "Clave de rango de la tabla DynamoDB"
  type        = string
}

variable "attributes" {
  description = "Lista de atributos de la tabla, incluyendo nombre y tipo"
  type = list(object({
    name = string
    type = string  # 'S' (String), 'N' (Number), etc.
  }))
}

variable "global_secondary_index" {
  description = "Definición del índice secundario global (GSI), opcional"
  type = object({
    name            = string
    hash_key        = string
    projection_type = string
  })
  default = null  # Permite que sea opcional
}

variable "tags" {
  description = "Etiquetas para la tabla"
  type        = map(string)
  default     = {}
}

variable "roles_lambda_principals" {
  description = "Lista de ARNs de los roles de Lambdas que tienen acceso a la tabla"
  type        = list(string)
}

variable "stream_enabled" {
  description = "Habilitar o no el stream en la tabla DynamoDB"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Tipo de vista del stream en la tabla DynamoDB (opcional)"
  type        = string
  default     = null
}
