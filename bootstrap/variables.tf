variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "infra_repo" {
  type = object({
    owner     = string
    name      = string
    role_name = string
    workflows = list(string)
  })
  default = {
    owner     = "Vandcarlos"
    name      = "object-classifier-infra"
    role_name = "oc-infra-deployer"
    workflows = ["terraform-plan.yml", "terraform-apply.yml"]
  }
}

variable "state_bucket_name" {
  type    = string
  default = "tfstate-vandcarlos-object-classifier"
}

variable "lock_table_name" {
  type    = string
  default = "tf-state-locks"
}
