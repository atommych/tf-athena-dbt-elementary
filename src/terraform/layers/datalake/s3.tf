resource "aws_s3_bucket" "datalake_s3_resource" {
  bucket = "${var.prefix}-datalake-${var.environment}"
  tags = {
    Environment = var.environment,
    Prefix      = var.prefix
    Region      = var.region
  }
}

# S3 static website bucket
resource "aws_s3_bucket" "atommych-terraform-state" {
  bucket = "atommych-terraform-state"
  tags = {
    Name = "atommych-terraform-state"
  }
}