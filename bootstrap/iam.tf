resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = concat(
        ["repo:${var.infra_repo.owner}/${var.infra_repo.name}:*"],
        [for w in var.infra_repo.workflows : "repo:${var.infra_repo.owner}/${var.infra_repo.name}:workflow:${w}"]
      )
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.infra_repo.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Project = "object-classifier"
    Repo    = "${var.infra_repo.owner}/${var.infra_repo.name}"
    Purpose = "Terraform-OIDC"
  }
}
