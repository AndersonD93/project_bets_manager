resource "aws_dynamodb_table" "dynamo_table" {
  name           = "${var.table_name}_IAC"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key
  range_key      = var.range_key

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index != null ? [var.global_secondary_index] : []
    content {
      name               = global_secondary_index.value["name"]
      hash_key           = global_secondary_index.value["hash_key"]
      projection_type    = global_secondary_index.value["projection_type"]
    }
  }

  # Stream settings (optional)
  stream_enabled = var.stream_enabled

  stream_view_type = var.stream_enabled && var.stream_view_type != null ? var.stream_view_type : null

  tags = {Project:var.project}
}

resource "aws_dynamodb_resource_policy" "dynamo_policy" {
  resource_arn = aws_dynamodb_table.dynamo_table.arn
  policy       = data.aws_iam_policy_document.dynamo_table_policy.json
}

data "aws_iam_policy_document" "dynamo_table_policy" {
  statement {
    sid    = "AllowAccessToDynamoTable"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.roles_lambda_principals
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
      aws_dynamodb_table.dynamo_table.arn,
      "${aws_dynamodb_table.dynamo_table.arn}/index/*"
    ]
  }
}

