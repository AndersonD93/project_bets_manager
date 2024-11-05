locals {
  response_models = {
    for key, resource in var.api_resources :
    key => (resource.response_models != {} ? resource.response_models : {})
  }

  request_templates = {
    for key, resource in var.api_resources :
    key => (resource.request_templates != {} ? resource.request_templates : {})
  }

  uri = var.uri != null ? var.uri : null

}
