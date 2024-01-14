# S3 static website bucket
resource "aws_s3_bucket" "dbt-docs-static-website" {
  bucket = "${var.prefix}-dbt-docs"
  tags = {
    Name = "dbt-docs-static-website"
  }
}

resource "aws_s3_bucket_website_configuration" "dbt-docs-static-website" {
  bucket = aws_s3_bucket.dbt-docs-static-website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "dbt-docs-static-website" {
  bucket = aws_s3_bucket.dbt-docs-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ACL access
resource "aws_s3_bucket_ownership_controls" "dbt-docs-static-website" {
  bucket = aws_s3_bucket.dbt-docs-static-website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "dbt-docs-static-website" {
  bucket = aws_s3_bucket.dbt-docs-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "dbt-docs-static-website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.dbt-docs-static-website,
    aws_s3_bucket_public_access_block.dbt-docs-static-website,
  ]

  bucket = aws_s3_bucket.dbt-docs-static-website.id
  acl    = "public-read"
}

# s3 static website url
output "website_url" {
  value = "http://${aws_s3_bucket.dbt-docs-static-website.bucket}.s3-website.${var.region}.amazonaws.com"
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.dbt-docs-static-website.id

  policy = <<POLICY
            {
              "Id": "Policy",
              "Statement": [
                {
                  "Action": [
                    "s3:GetObject"
                  ],
                  "Effect": "Allow",
                  "Resource": "arn:aws:s3:::${aws_s3_bucket.dbt-docs-static-website.bucket}/*",
                  "Principal": {
                    "AWS": [
                      "*"
                    ]
                  }
                }
              ]
            }
            POLICY
}