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

  schedule = "0 5 1 * ? *" # Run at 5:00 am (UTC+0) every 1st day of the month

  input = [
    {
      source = aws_s3_bucket.datalake_s3_resource.arn
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

