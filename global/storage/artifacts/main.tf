data "aws_caller_identity" "me" {}

locals {
  producer_arns = {
    for k, v in var.producers :
    k => "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/${v.role_name}"
  }
  consumer_arns = {
    for k, v in var.consumers :
    k => "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/${v.role_name}"
  }
}

data "aws_iam_policy_document" "artifacts_bp" {
  # List para produtores e consumidores nos seus prefixos
  dynamic "statement" {
    for_each = var.producers
    content {
      sid       = "ListRaw_${statement.key}"
      effect    = "Allow"
      actions   = ["s3:ListBucket"]
      resources = ["arn:aws:s3:::${var.artifacts_bucket_name}"]
      principals {
        type        = "AWS"
        identifiers = [local.producer_arns[statement.key]]
      }
      condition {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = ["raw/${statement.value.project_key}/*"]
      }
    }
  }
  dynamic "statement" {
    for_each = var.consumers
    content {
      sid       = "ListConverted_${statement.key}"
      effect    = "Allow"
      actions   = ["s3:ListBucket"]
      resources = ["arn:aws:s3:::${var.artifacts_bucket_name}"]
      principals {
        type        = "AWS"
        identifiers = [local.consumer_arns[statement.key]]
      }
      condition {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = ["converted/${statement.value.project_key}/*"]
      }
    }
  }

  # Produtores: CRUD só em raw/<project>/*
  dynamic "statement" {
    for_each = var.producers
    content {
      sid       = "ProducerRawCRUD_${statement.key}"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:AbortMultipartUpload", "s3:PutObjectTagging"]
      resources = ["arn:aws:s3:::${var.artifacts_bucket_name}/raw/${statement.value.project_key}/*"]
      principals {
        type        = "AWS"
        identifiers = [local.producer_arns[statement.key]]
      }
    }
  }

  # Consumidores: Get só em converted/<project>/*
  dynamic "statement" {
    for_each = var.consumers
    content {
      sid       = "ConsumerConvertedGet_${statement.key}"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:GetObjectTagging"]
      resources = ["arn:aws:s3:::${var.artifacts_bucket_name}/converted/${statement.value.project_key}/*"]
      principals {
        type        = "AWS"
        identifiers = [local.consumer_arns[statement.key]]
      }
    }
  }

  dynamic "statement" {
    for_each = var.converter_role_arn == null ? [] : [1]
    content {
      sid    = "ConverterRW"
      effect = "Allow"
      actions = [
        "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
        "s3:AbortMultipartUpload", "s3:PutObjectTagging"
      ]
      resources = [
        "arn:aws:s3:::${var.artifacts_bucket_name}/raw/*",
        "arn:aws:s3:::${var.artifacts_bucket_name}/converted/*",
        "arn:aws:s3:::${var.artifacts_bucket_name}/manifests/*"
      ]
      principals {
        type        = "AWS"
        identifiers = [var.converter_role_arn]
      }
    }
  }

}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  policy = data.aws_iam_policy_document.artifacts_bp.json
}
