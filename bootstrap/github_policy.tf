data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    sid    = "AllowManageOcRoles"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/oc-*"
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_inline" {
  name   = "github-actions-permissions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}
