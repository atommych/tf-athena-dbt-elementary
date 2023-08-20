resource "snowflake_database" "sf_raw_db" {
  name                        = upper("${var.environment}_RAW_SGA_DB")
  comment                     = "The Database for Raw Data"
  data_retention_time_in_days = 14
}

resource "snowflake_database" "sf_gold_db" {
  name                        = upper("${var.environment}_GOLD_SGA_DB")
  comment                     = "The Database for  Data Products - tables and views accessible to analysts and reporting"
  data_retention_time_in_days = 14
}