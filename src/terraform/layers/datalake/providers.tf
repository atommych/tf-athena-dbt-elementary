terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56"
    }
  }
}

provider "aws" {
  region = var.aws.region
  access_key = var.aws.access_key
  secret_key = var.aws.secret_key
}

module "athena-stack" {
  source  = "datamesh-architecture/dataproduct-aws-athena/aws"
  version = "0.2.1"

  aws    = var.aws
  domain = var.prefix
  name   = "mockup"

  schedule = "0 0 1 * * *" # Run at 00:00 am (UTC) every month on 1st day

  input = [
    {
      source = "${var.prefix}-datalake-${var.environment}"
    }
  ]

  transform = {
    query = "sql/mockup.sql"
  }

  output = {
    format = "csv"
    schema = "schema/mockup.schema.json"
  }
}

