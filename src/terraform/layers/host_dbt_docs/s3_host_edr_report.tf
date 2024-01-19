# S3 static website bucket
resource "aws_s3_bucket" "edr-report-static-website" {
  bucket = "${var.prefix}-edr-report"
  tags = {
    Name = "edr-report-static-website"
  }
}

resource "aws_s3_bucket_website_configuration" "edr-report-static-website" {
  bucket = aws_s3_bucket.edr-report-static-website.id

  index_document {
    suffix = "elementary_report.html"
  }

  error_document {
    key = "elementary_report.html"
  }
}

resource "aws_s3_bucket_versioning" "edr-report-static-website" {
  bucket = aws_s3_bucket.edr-report-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ACL access
resource "aws_s3_bucket_ownership_controls" "edr-report-static-website" {
  bucket = aws_s3_bucket.edr-report-static-website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "edr-report-static-website" {
  bucket = aws_s3_bucket.edr-report-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "edr-report-static-website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.edr-report-static-website,
    aws_s3_bucket_public_access_block.edr-report-static-website,
  ]

  bucket = aws_s3_bucket.edr-report-static-website.id
  acl    = "public-read"
}

# s3 static website url
output "edr_report_website_url" {
  value = "http://${aws_s3_bucket.edr-report-static-website.bucket}.s3-website.${var.region}.amazonaws.com"
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "edr-report-bucket-policy" {
  bucket = aws_s3_bucket.edr-report-static-website.id

  policy = <<POLICY
            {
              "Id": "Policy",
              "Statement": [
                {
                  "Action": [
                    "s3:GetObject"
                  ],
                  "Effect": "Allow",
                  "Resource": "arn:aws:s3:::${aws_s3_bucket.edr-report-static-website.bucket}/*",
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