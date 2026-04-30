resource "aws_iam_policy" "ssm_champion_policy" {
  name        = "ssm-champion-policy"
  description = "Permite a las Lambdas leer/escribir parámetros SSM de campeón"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:PutParameter"]
        Resource = "arn:aws:ssm:${var.region}:*:parameter/bets-manager/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "put_champion_ssm" {
  role       = module.lambdas_backend_api.lambda_role_name["put_champion"]
  policy_arn = aws_iam_policy.ssm_champion_policy.arn
}

resource "aws_iam_role_policy_attachment" "get_champion_ssm" {
  role       = module.lambdas_backend_api.lambda_role_name["get_champion"]
  policy_arn = aws_iam_policy.ssm_champion_policy.arn
}

resource "aws_iam_role_policy_attachment" "manage_champion_config_ssm" {
  role       = module.lambdas_backend_api.lambda_role_name["manage_champion_config"]
  policy_arn = aws_iam_policy.ssm_champion_policy.arn
}

resource "aws_iam_role_policy_attachment" "set_tournament_champion_ssm" {
  role       = module.lambdas_backend_api.lambda_role_name["set_tournament_champion"]
  policy_arn = aws_iam_policy.ssm_champion_policy.arn
}

resource "aws_iam_role_policy_attachment" "get_tournament_champion_ssm" {
  role       = module.lambdas_backend_api.lambda_role_name["get_tournament_champion"]
  policy_arn = aws_iam_policy.ssm_champion_policy.arn
}
