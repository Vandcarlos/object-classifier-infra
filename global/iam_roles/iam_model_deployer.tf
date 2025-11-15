########################################
# oc-model-deployer
########################################

data "aws_iam_policy_document" "oc_model_deployer_assume" {
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

    # Amarrado ao repo de modelo
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:Vandcarlos/object-classifier-model:*",
      ]
    }
  }
}

resource "aws_iam_role" "oc_model_deployer" {
  name               = "oc-model-deployer"
  description        = "CI/CD role for object-classifier-model repository (training + model publish)"
  assume_role_policy = data.aws_iam_policy_document.oc_model_deployer_assume.json

  tags = {
    Project   = "object-classifier"
    Component = "model"
  }
}

data "aws_iam_policy_document" "oc_model_deployer_policy" {
  # SageMaker (apenas TRAINING; nada de endpoint aqui)
  statement {
    sid    = "SageMakerTraining"
    effect = "Allow"

    actions = [
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:ListTrainingJobs",
    ]

    resources = ["*"]
  }

  # ECR para imagens de treino
  statement {
    sid    = "ECRAccessForTrainingImages"
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

  # Logs básicos
  statement {
    sid    = "CloudWatchLogsForTraining"
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

  # Se você criar roles de runtime de treino (oc-train-runtime-*),
  # libera o PassRole aqui depois:
  #
  # statement {
  #   sid    = "PassTrainingRuntimeRoles"
  #   effect = "Allow"
  #
  #   actions = ["iam:PassRole"]
  #   resources = [
  #     "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/oc-train-runtime-*",
  #   ]
  # }
}

resource "aws_iam_role_policy" "oc_model_deployer_policy_attach" {
  role   = aws_iam_role.oc_model_deployer.name
  policy = data.aws_iam_policy_document.oc_model_deployer_policy.json
}
