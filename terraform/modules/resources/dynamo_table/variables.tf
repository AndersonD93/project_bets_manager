variable "project" {
  default = "bets-manager"
}
/*
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
*/

variable "dynamo_tables" {
  description = "Lista de tablas de dynamo"

  type = map(object({
    table_name              = string,
    hash_key                = string,
    range_key               = string,
    attributes              = list(map(string)),
    stream_enabled          = optional(bool),
    stream_view_type        = optional(string),
    global_secondary_index  = optional(map(string)),
    tags                    = optional(map(string))
    })
  )
}
