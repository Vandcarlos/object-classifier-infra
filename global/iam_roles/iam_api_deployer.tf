########################################
# oc-api-deployer
########################################

data "aws_iam_policy_document" "oc_api_deployer_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Amarrado ao repo da API externa
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:Vandcarlos/object-classifier-api:*",
      ]
    }
  }
}

resource "aws_iam_role" "oc_api_deployer" {
  name               = "oc-api-deployer"
  description        = "CI/CD role for object-classifier-api repository (public API layer)"
  assume_role_policy = data.aws_iam_policy_document.oc_api_deployer_assume.json

  tags = {
    Project   = "object-classifier"
    Component = "api-edge"
  }
}

data "aws_iam_policy_document" "oc_api_deployer_policy" {
  # ECS + ALB (se você usar ECS pra API)
  statement {
    sid    = "ECSAndALBForApi"
    effect = "Allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:DescribeClusters",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:ListClusters",
      "ecs:ListServices",

      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]

    resources = ["*"]
  }

  # API Gateway (se você escolher esse caminho)
  statement {
    sid    = "ApiGatewayForPublicApi"
    effect = "Allow"

    actions = [
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:PATCH",
      "apigateway:DELETE",
      "apigateway:TagResource",
      "apigateway:UntagResource",
    ]

    resources = ["*"]
  }

  # Lambda (se a API for Lambda-based)
  statement {
    sid    = "LambdaForApi"
    effect = "Allow"

    actions = [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:ListFunctions",
      "lambda:AddPermission",
      "lambda:RemovePermission",
    ]

    resources = ["*"]
  }

  # PassRole para roles de runtime da API
  statement {
    sid    = "PassApiRuntimeRoles"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/oc-api-runtime-*",
    ]
  }

  # Logs
  statement {
    sid    = "CloudWatchLogsForApi"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "oc_api_deployer_policy_attach" {
  role   = aws_iam_role.oc_api_deployer.name
  policy = data.aws_iam_policy_document.oc_api_deployer_policy.json
}
