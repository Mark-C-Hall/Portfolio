provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab-tf-state"
    key            = "portfolio/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}