variable "lambda_map" {
  description = "lambdas backend"

  type = map(object({
    lambda_name           = string,
    lambda_zip            = string,
    handler               = string,
    runtime               = string
    source_arn            = string,
    environment_variables = optional(map(string))
    })
  )
}
