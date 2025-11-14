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
  source = "./global/iam_github"

  aws_region = var.aws_region
  repos = {
    model = {
      owner     = "Vandcarlos"
      name      = "object-classifier-model"
      role_name = "oc-model-deployer"
    }
    api = {
      owner     = "Vandcarlos"
      name      = "object-classifier-api"
      role_name = "oc-api-deployer"
    }
  }
}

module "artifacts" {
  source = "./global/storage/artifacts"

  bucket_name = "oc-artifacts-vandcarlos-ml"
  producers = {
    model = {
      role_arn   = module.iam_github.roles["model"].arn
      prefix     = "models/"
    }
  }
  consumers = {
    api = {
      role_arn = module.iam_github.roles["api"].arn
      prefix   = "models/"
    }
  }
}
