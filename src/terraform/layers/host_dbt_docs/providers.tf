terraform {
  backend "s3" {
    bucket         = "atommych-terraform-state"
    key            = "Terraform-State"
  }
}

provider "aws" {
}
