data "aws_iam_policy_document" "assume_role" {
  for_each = var.allowed_repos

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
      values   = ["repo:${each.value.owner}/${each.value.name}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  for_each           = var.allowed_repos
  name               = each.value.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  tags = {
    Project = "object-classifier"
    Repo    = "${each.value.owner}/${each.value.name}"
    Purpose = "Terraform-OIDC"
  }
}
