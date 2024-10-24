resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.lambda_name}-policy"
  description = "Policy for Lambda ${var.lambda_name}"

  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:GetResourcePolicy"
    ]

    resources = ["*"] #pendiente
  }
   statement {
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    effect = "Allow"
    resources = ["*"] #pendiente
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect = "Allow"
    resources = ["*"]#pendiente
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
