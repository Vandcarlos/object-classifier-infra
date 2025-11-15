terraform {
  backend "s3" {
    bucket         = "tfstate-vandcarlos-object-classifier"
    key            = "object-classifier-infra/global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-ml-locks"
    encrypt        = true
  }
}
