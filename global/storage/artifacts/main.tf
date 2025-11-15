data "aws_iam_policy_document" "artifacts_bp" {

  ########################################
  # Producers: podem ler/escrever no seu prefixo
  ########################################
  # Permissão de Put/Get/Delete no prefixo
  dynamic "statement" {
    for_each = var.producers
    content {
      sid    = "ProducerObjects_${statement.key}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [statement.value.arn]
      }

      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
      ]

      resources = [
        "${aws_s3_bucket.artifacts.arn}/${statement.value.prefix}*",
      ]
    }
  }

  # Permissão de ListBucket, restrita ao prefixo
  dynamic "statement" {
    for_each = var.producers
    content {
      sid    = "ProducerList_${statement.key}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [statement.value.arn]
      }

      actions   = ["s3:ListBucket"]
      resources = [aws_s3_bucket.artifacts.arn]

      condition {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = ["${statement.value.prefix}*"]
      }
    }
  }

  ########################################
  # Consumers: só leitura no prefixo
  ########################################
  dynamic "statement" {
    for_each = var.consumers
    content {
      sid    = "ConsumerObjects_${statement.key}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [statement.value.arn]
      }

      actions = [
        "s3:GetObject",
      ]

      resources = [
        "${aws_s3_bucket.artifacts.arn}/${statement.value.prefix}*",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.consumers
    content {
      sid    = "ConsumerList_${statement.key}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [statement.value.arn]
      }

      actions   = ["s3:ListBucket"]
      resources = [aws_s3_bucket.artifacts.arn]

      condition {
        test     = "StringLike"
        variable = "s3:prefix"
        values   = ["${statement.value.prefix}*"]
      }
    }
  }

  ########################################
  # Converter (opcional): full access no bucket
  ########################################
  dynamic "statement" {
    for_each = var.converter_role_arn == null ? [] : [1]
    content {
      sid    = "ConverterFullAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [var.converter_role_arn]
      }

      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
      ]

      resources = [
        aws_s3_bucket.artifacts.arn,
        "${aws_s3_bucket.artifacts.arn}/*",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  policy = data.aws_iam_policy_document.artifacts_bp.json
}
