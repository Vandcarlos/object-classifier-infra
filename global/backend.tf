terraform {
  backend "s3" {
    bucket         = "tfstate-vandcarlos-object-classifier"
    key            = "infra/bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-ml-locks"
    encrypt        = true
  }
}
