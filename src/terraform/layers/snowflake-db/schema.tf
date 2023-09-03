resource "snowflake_schema" "landing_zone" {
  database = snowflake_database.sf_raw_db.name
  name     = "${var.landing_zone_schema}"
  comment  = "The Landing zone schema for new data"

  is_transient        = false
  is_managed          = false
}

resource "snowflake_schema" "analytics" {
  database = snowflake_database.sf_gold_db.name
  name     = "${var.analytics_schema}"
  comment  = "The Landing zone schema for new data"

  is_transient        = false
  is_managed          = false
}
