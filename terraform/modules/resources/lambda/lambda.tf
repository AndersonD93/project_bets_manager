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

resource "aws_lambda_permission" "lambda_permission" {
  for_each      = var.lambda_map
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = each.value.source_arn
}
