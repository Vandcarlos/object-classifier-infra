output "artifacts_bucket_name" {
  description = "Nome do bucket de artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN do bucket de artifacts"
  value       = aws_s3_bucket.artifacts.arn
}
