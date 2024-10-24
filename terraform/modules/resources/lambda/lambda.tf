resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.lambda_name}-IAC"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  filename      = var.lambda_zip

  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.source_arn
}
