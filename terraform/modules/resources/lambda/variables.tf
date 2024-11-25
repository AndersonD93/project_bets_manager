variable "lambda_map" {
  description = "lambdas backend"

  type = map(object({
    lambda_name           = string,
    lambda_zip            = string,
    handler               = string,
    runtime               = string,
    environment_variables = optional(map(string))
    })
  )
}
