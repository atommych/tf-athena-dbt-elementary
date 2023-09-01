resource "snowflake_warehouse" "sf_reporting_wh" {
    name           = "REPORTING_WH"
    warehouse_size = "x-small"
    auto_suspend   = 60
}

resource "snowflake_warehouse" "sf_transforming_wh" {
    name           = "TRANSFORMING_WH"
    warehouse_size = "x-small"
    auto_suspend   = 60
}

resource "snowflake_warehouse" "sf_loading_wh" {
    name           = "LOADING_WH"
    warehouse_size = "x-small"
    auto_suspend   = 60
}
