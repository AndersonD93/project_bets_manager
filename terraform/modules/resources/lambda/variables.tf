variable "lambda_name" {
  description = "Nombre de la función Lambda"
}

variable "lambda_zip" {
  description = "Ruta del archivo zip con el código Lambda"
}

variable "handler" {
  description = "Nombre del archivo handler para Lambda"
}

variable "runtime" {
  description = "Runtime de la Lambda (ej. nodejs14.x, python3.8)"
}

variable "environment_variables" {
  description = "Variables de entorno para la Lambda"
  type        = map(string)
  default     = {}
}

variable "source_arn" {
  type        = string
  description = "arn para recurso aws_lambda_permission"
}

