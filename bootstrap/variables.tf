variable "project" {
  type    = string
  default = "object-classifier"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "infra_repo" {
  description = "Repositório de infra que pode assumir a role oc-infra-deployer"
  type = object({
    owner     = string
    name      = string
    role_name = string
  })
  default = {
    owner     = "Vandcarlos"
    name      = "object-classifier-infra"
    role_name = "oc-infra-deployer"
  }
}

variable "state_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para Terraform state"
  default     = "tfstate-vandcarlos-object-classifier"
}

variable "lock_table_name" {
  type        = string
  description = "Nome da tabela DynamoDB para Terraform lock"
  default     = "tfstate-ml-locks"
}
