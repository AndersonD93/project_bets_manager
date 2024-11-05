variable "api_id" {
  type = string
}

variable "api_root_resource_id" {
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

/*
variable "passthrough_behavior" {
  description = "Comportamiento de paso a través de la integración"
  type = string
  default = null
  validation {
    condition = var.request_templates == {} || var.passthrough_behavior != null
    error_message = "passthrough_behavior es obligatorio si se proporcionan request_templates."
  }
}
*/

variable "uri" {
  description = "URI de la integración"
  type        = string
  default     = null
  validation {
    condition = var.uri == null && var.type_integration != "MOCK"
    error_message = "uri es obligatorio cuando type_integration no es MOCK."
  }
}

variable "api_resources" {
  description = "Mapa de recursos del api gateway"

  type = map(object({
    resource_id          = string,
    http_method          = string,
    authorization        = string,
    authorizer_id        = optional(string)
    type_integration     = string,
    uri                  = optional(string)
    request_templates    = optional(map(string)),
    passthrough_behavior = optional(string),
    response_models      = optional(map(string)),
    stage_name           = string
    })
  )
}

variable "region" {
  default = "us-east-1"
}
