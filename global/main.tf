terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "me" {}

module "iam_github" {
  source = "./iam_github"

  allowed_repos = {
    model = {
      owner     = "Vandcarlos"
      name      = "object-classifier-model"
      role_name = "oc-model-deployer"
    }
  }
}

module "artifacts" {
  source = "./storage/artifacts"

  artifacts_bucket_name = "ml-artifacts-${data.aws_caller_identity.me.account_id}"

  producers = {
    model = {
      role_name   = module.iam_github.roles["model"].role_name
      project_key = module.iam_github.roles["model"].name
    }
  }

  consumers = {
  }
}
