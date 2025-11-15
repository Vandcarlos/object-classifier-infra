output "infra_role_arn" {
  description = "ARN da role oc-infra-deployer para configurar no GitHub Actions"
  value       = aws_iam_role.oc_infra_deployer.arn
}

output "tf_state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "tf_lock_table" {
  value = aws_dynamodb_table.tf_lock.name
}
