resource "aws_lambda_function" "lambda_function" {
  for_each      = var.lambda_map
  function_name = "${each.value.lambda_name}-IAC"
  role          = aws_iam_role.lambda_role[each.key].arn
  handler       = each.value.handler
  runtime       = each.value.runtime
  filename      = each.value.lambda_zip

  environment {
    variables = each.value.environment_variables
  }
}

