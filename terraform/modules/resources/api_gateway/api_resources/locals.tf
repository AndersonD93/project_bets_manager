# Recurso adicional para response_models, si se necesita
locals {
  response_models   = var.response_models != {} ? var.response_models : {}
  request_templates = var.request_templates != {} ? var.request_templates : {}
}