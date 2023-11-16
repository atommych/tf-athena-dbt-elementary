locals {
  catalog_name = "${var.prefix}-catalog-${var.environment}"
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = local.catalog_name
}

resource "aws_athena_workgroup" "aws_athena_workgroup" {
  name = "${var.prefix}-athena-workgroup-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.datalake_s3_resource.bucket}/output/query/"
    }
  }
}

