locals {
  allowed_principals = {
    for k, v in var.allowed_repos :
    k => "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/${v.role_name}"
  }
}

data "aws_iam_policy_document" "tfstate_bucket" {
  # ListBucket restrito por prefixo
  dynamic "statement" {
    for_each = var.allowed_repos
    content {
      sid       = "AllowList_${statement.key}"
      effect    = "Allow"
      actions   = ["s3:ListBucket"]
      resources = ["arn:aws:s3:::${var.state_bucket_name}"]
      principals {
        type        = "AWS"
        identifiers = [local.allowed_principals[statement.key]]
      }
      condition {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = ["${statement.value.state_prefix}/*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.allowed_repos
    content {
      sid       = "AllowCRUD_${statement.key}"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:AbortMultipartUpload"]
      resources = ["arn:aws:s3:::${var.state_bucket_name}/${statement.value.state_prefix}/*"]
      principals {
        type        = "AWS"
        identifiers = [local.allowed_principals[statement.key]]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate_bucket" {
  bucket = var.state_bucket_name
  policy = data.aws_iam_policy_document.tfstate_bucket.json
}
