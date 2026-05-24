data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "deploy" {
  name = "${var.project}-github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:takao-Tokunaga/aws-study:*" }
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
      }
    }]
  })
}

resource "aws_iam_role_policy" "deploy" {
  name = "${var.project}-github-actions-deploy-policy"
  role = aws_iam_role.deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # SSM Run Command で EC2 にデプロイ
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      },
      {
        # デプロイ対象 EC2 の特定
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  })
}
