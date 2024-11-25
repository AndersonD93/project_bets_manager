resource "aws_lambda_permission" "lambda_permission" {
  for_each      = var.mapping_lambda_permission_api
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}