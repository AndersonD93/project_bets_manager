variable "lambda_map" {
  description = "lambdas backend"

  type = map(object({
    lambda_name           = string,
    handler               = string,
    runtime               = string,
    environment_variables = optional(map(string))
    })
  )
}
