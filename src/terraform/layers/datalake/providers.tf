terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56"
    }
  }
}

provider "aws" {
}
