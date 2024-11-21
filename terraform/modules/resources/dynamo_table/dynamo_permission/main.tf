resource "aws_dynamodb_resource_policy" "dynamo_policy" {
  for_each     = var.mapping_dynamo_permission
  resource_arn = each.value.table_arn
  policy       = data.aws_iam_policy_document.dynamo_table_policy[each.key].json
}

data "aws_iam_policy_document" "dynamo_table_policy" {
  for_each = var.mapping_dynamo_permission
  statement {
    sid    = "AllowAccessToDynamoTable"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = each.value.roles_lambda_principals
    }

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = [
      each.value.table_arn,
      "${each.value.table_arn}/index/*"
    ]
  }
}

