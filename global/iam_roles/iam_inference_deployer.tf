########################################
# oc-inference-deployer
########################################

data "aws_iam_policy_document" "oc_inference_deployer_assume" {
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

    # Amarrado ao repo de inferência
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:Vandcarlos/object-classifier-inference:*",
      ]
    }
  }
}

resource "aws_iam_role" "oc_inference_deployer" {
  name               = "oc-inference-deployer"
  description        = "CI/CD role for object-classifier-inference repository (SageMaker models/endpoints)"
  assume_role_policy = data.aws_iam_policy_document.oc_inference_deployer_assume.json

  tags = {
    Project   = "object-classifier"
    Component = "inference"
  }
}

data "aws_iam_policy_document" "oc_inference_deployer_policy" {
  # Gerenciar modelos + endpoints no SageMaker
  statement {
    sid    = "SageMakerModelAndEndpoint"
    effect = "Allow"

    actions = [
      "sagemaker:CreateModel",
      "sagemaker:DeleteModel",
      "sagemaker:DescribeModel",
      "sagemaker:ListModels",

      "sagemaker:CreateEndpointConfig",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:ListEndpointConfigs",

      "sagemaker:CreateEndpoint",
      "sagemaker:UpdateEndpoint",
      "sagemaker:DeleteEndpoint",
      "sagemaker:DescribeEndpoint",
      "sagemaker:ListEndpoints",
    ]

    resources = ["*"]
  }

  # ECR para imagem de inferência (se você publicar a image Docker de inferência via pipeline)
  statement {
    sid    = "ECRAccessForInferenceImages"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]

    resources = ["*"]
  }

  # PassRole para as runtime roles usadas pelo endpoint (ex: oc-inference-runtime-sagemaker)
  statement {
    sid    = "PassInferenceRuntimeRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/oc-inference-runtime-*",
    ]
  }

  # Logs
  statement {
    sid    = "CloudWatchLogsForInferenceInfra"
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

resource "aws_iam_role_policy" "oc_inference_deployer_policy_attach" {
  role   = aws_iam_role.oc_inference_deployer.name
  policy = data.aws_iam_policy_document.oc_inference_deployer_policy.json
}
