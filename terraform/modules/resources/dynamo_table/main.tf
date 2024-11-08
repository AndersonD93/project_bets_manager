resource "aws_dynamodb_table" "dynamo_table" {
  for_each       = var.dynamo_tables   
  name           = "${each.value.table_name}_modules_IAC"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = each.value.hash_key
  range_key      = each.value.range_key

  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Lógica condicional para stream_specification
  stream_enabled   = each.value.stream_enabled != null ? each.value.stream_enabled : false
  stream_view_type = each.value.stream_view_type != null ? each.value.stream_view_type : "NEW_AND_OLD_IMAGES"

  dynamic "global_secondary_index" {
    for_each       = each.value.global_secondary_index != null ? [each.value.global_secondary_index] : []
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      projection_type = global_secondary_index.value.projection_type
    }
  }
  tags = each.value.tags != null ? each.value.tags : {}
}

resource "aws_dynamodb_resource_policy" "dynamo_policy" {
  for_each     = var.dynamo_tables
  resource_arn = aws_dynamodb_table.dynamo_table[each.key].arn
  policy       = data.aws_iam_policy_document.dynamo_table_policy[each.key].json
}

data "aws_iam_policy_document" "dynamo_table_policy" {
  for_each     = var.dynamo_tables
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
      aws_dynamodb_table.dynamo_table[each.key].arn,
      "${aws_dynamodb_table.dynamo_table[each.key].arn}/index/*"
    ]
  }
}

