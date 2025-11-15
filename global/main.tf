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

locals {
  github_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.me.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

module "iam_github" {
  source = "./iam_github"

  github_oidc_provider_arn = local.github_oidc_provider_arn
}

module "artifacts_bucket" {
  source = "./storage/artifacts"

  artifacts_bucket_name = "oc-artifacts-${var.env}" # ou algo fixo

  producers = {
    model = {
      arn    = module.iam_github.oc_model_deployer_role_arn
      prefix = "models/"
    }
    inference = {
      arn    = module.iam_github.oc_inference_deployer_role_arn
      prefix = "inference/"
    }
  }

  consumers = {
    api = {
      arn    = module.iam_github.oc_api_deployer_role_arn
      prefix = "inference/"   # API lê a saída de inferência, por exemplo
    }
  }
}