locals {
  allowed_principal = aws_iam_role.github_actions.arn
}

data "aws_iam_policy_document" "tfstate_bucket" {
  # ListBucket restrito por prefixo
  statement {
    sid       = "AllowList_TFState"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tf_state.arn]
    principals {
      type        = "AWS"
      identifiers = [local.allowed_principal]
    }
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.infra_repo.name}/*"]
    }
  }

  statement {
    sid    = "AllowCRUD_TFState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload"
    ]
    resources = ["${aws_s3_bucket.tf_state.arn}/${var.infra_repo.name}/*"]
    principals {
      type        = "AWS"
      identifiers = [local.allowed_principal]
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate_bucket" {
  bucket = var.state_bucket_name
  policy = data.aws_iam_policy_document.tfstate_bucket.json
}
