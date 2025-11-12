data "aws_iam_policy_document" "lock_table" {
  dynamic "statement" {
    for_each = var.allowed_repos
    content {
      sid    = "AllowLock_${statement.key}"
      effect = "Allow"
      actions = [
        "dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem",
        "dynamodb:UpdateItem", "dynamodb:DescribeTable"
      ]
      resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.me.account_id}:table/${var.lock_table_name}"]
      principals {
        type        = "AWS"
        identifiers = [aws_iam_role.child[statement.key].arn]
      }
    }
  }
}

resource "aws_dynamodb_resource_policy" "lock_table" {
  resource_arn = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.me.account_id}:table/${var.lock_table_name}"
  policy       = data.aws_iam_policy_document.lock_table.json
}
