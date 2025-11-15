output "oc_model_deployer_role_arn" {
  description = "ARN da role de deploy do repo object-classifier-model"
  value       = aws_iam_role.oc_model_deployer.arn
}

output "oc_inference_deployer_role_arn" {
  description = "ARN da role de deploy do repo object-classifier-inference"
  value       = aws_iam_role.oc_inference_deployer.arn
}

output "oc_api_deployer_role_arn" {
  description = "ARN da role de deploy do repo object-classifier-api"
  value       = aws_iam_role.oc_api_deployer.arn
}
