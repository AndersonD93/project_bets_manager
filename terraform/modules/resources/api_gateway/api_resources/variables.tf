variable "api_id" {
  type = string
}

variable "api_root_resource_id" {
  type = string
}

variable "path_part" {  
  type = string  
}

variable "http_method" {
  type = string
}

variable "authorization" {
  type = string
  default = "NONE"
  validation {
    condition = contains(["NONE", "CUSTOM", "AWS_IAM","COGNITO_USER_POOLS"], var.authorization)
    error_message = "Error los valores validos son NONE,CUSTOM,AWS_IAM,COGNITO_USER_POOLS"
  }
}

variable "type_integration"{
    type = string
    default = "HTTP"
    validation {
    condition = contains(["AWS", "AWS_PROXY", "HTTP", "MOCK", "HTTP_PROXY"], var.type_integration)
    error_message = "Error los valores validos son AWS,AWS_PROXY,HTTP,MOCK,HTTP_PROXY"
  }
}

variable "request_templates" {
  description = "Plantillas de solicitud para la API"
  type        = map(string)
}

variable "passthrough_behavior" {
  description = "Comportamiento de paso a través de la integración"
  type = string
  default = null
  validation {
    condition = var.request_templates == {} || var.passthrough_behavior != null
    error_message = "passthrough_behavior es obligatorio si se proporcionan request_templates."
  }
}

variable "response_models" {
  description = "Un mapa que especifica los recursos del modelo utilizados para el tipo de contenido de la respuesta"
  type        = map(string)
}

variable "stage_name"{
    type = string
}