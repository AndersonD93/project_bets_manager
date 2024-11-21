variable "name_api" {
  description = "nombre de api"
  type        = string
}

variable "description_api" {
  description = "descripción de funcionalidad api"
  type        = string
}

variable "type_endpoint" {
  description = "Lista de tipos de puntos finales. Si no se especifica, el valor predeterminado es EDGE"
  type        = string
  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.type_endpoint)
    error_message = "Los valores aceptados son EDGE, REGIONAL, PRIVATE"
  }
}

variable "path_part_list" {
  type = set(string)
}

