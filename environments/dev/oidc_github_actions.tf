########################################################
# GithubのOIDCに使用するIDプロバイダ
########################################################

data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github_actions.certificates[*].sha1_fingerprint
}


########################################################
# Github Actionsで使用するIAMロール
########################################################
data "aws_iam_policy_document" "github_oidc_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::184321346292:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # # 特定のリポジトリの特定のブランチからのみ認証を許可する
    # condition {
    #   test     = "StringEquals"
    #   variable = "token.actions.githubusercontent.com:sub"
    #   values   = ["repo:butterthon-dev/terraform-example:ref:refs/heads/main"]
    # }
    # 特定のリポジトリの全てのワークフローから認証を許可する場合はこっち
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:butterthon-dev/terraform-example:*"]
    }
  }
}

resource "aws_iam_role" "github_oidc" {
  name               = "${local.service_name}-role-github-oidc"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role_policy.json
}

########################################################
# Github Actionsで使用するIAMロールに追加のポリシーをアタッチ
########################################################
resource "aws_iam_policy" "github_oidc_policy" {
  name = "${local.service_name}-policy-github-oidc"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECRの認証
      {
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = ["*"]
      },

      # ECRにイメージPUSH
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [
          "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/viz-butterthon-dev-ecr-*"
        ]
      },

      # Lambdaの更新
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode"
        ]
        Resource = ["arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:viz-butterthon-dev-func-*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_oidc_policy" {
  role      = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_oidc_policy.arn
}
