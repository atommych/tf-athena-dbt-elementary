resource "tls_private_key" "svc_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "snowflake_user" "sf_demo_loader_user" {
    provider          = snowflake.security_admin
    name              = "sf_demo_loader_user"
    default_warehouse = snowflake_warehouse.sf_loading_wh.name
    default_role      = snowflake_role.sf_loader_role.name
    default_namespace = "${snowflake_database.sf_raw_db.name}.${snowflake_schema.landing_zone.name}"
    rsa_public_key    = substr(tls_private_key.svc_key.public_key_pem, 27, 398)
}

resource "snowflake_user" "sf_demo_transformer_user" {
    provider          = snowflake.security_admin
    name              = "sf_demo_transformer_user"
    default_warehouse = snowflake_warehouse.sf_transforming_wh.name
    default_role      = snowflake_role.sf_transformer_role.name
    default_namespace = "${snowflake_database.sf_gold_db.name}.${snowflake_schema.analytics.name}"
    rsa_public_key    = substr(tls_private_key.svc_key.public_key_pem, 27, 398)
}

resource "snowflake_user" "sf_demo_reporter_user" {
    provider          = snowflake.security_admin
    name              = "sf_demo_reporter_user"
    default_warehouse = snowflake_warehouse.sf_reporting_wh.name
    default_role      = snowflake_role.sf_reporter_role.name
    default_namespace = "${snowflake_database.sf_gold_db.name}.${snowflake_schema.analytics.name}"
    rsa_public_key    = substr(tls_private_key.svc_key.public_key_pem, 27, 398)
}

resource "snowflake_role" "sf_loader_role" {
  provider = snowflake.security_admin
  name     = "SF_ROLE_LOADER"
}

resource "snowflake_role" "sf_transformer_role" {
  provider = snowflake.security_admin
  name     = "SF_ROLE_TRANSFORMER"
}

resource "snowflake_role" "sf_reporter_role" {
  provider = snowflake.security_admin
  name     = "SF_ROLE_REPORTER"
}

resource "snowflake_grant_privileges_to_role" "db_grant_sf_loader_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_loader_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.sf_raw_db.name
  }
}

resource "snowflake_grant_privileges_to_role" "db_grant_gold_sf_transformer_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_transformer_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.sf_gold_db.name
  }
}

resource "snowflake_grant_privileges_to_role" "db_grant_raw_sf_transformer_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_transformer_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.sf_raw_db.name
  }
}

resource "snowflake_grant_privileges_to_role" "db_grant_sf_reporter_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_reporter_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.sf_gold_db.name
  }
}

resource "snowflake_grant_privileges_to_role" "sch_grant_sf_loader_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_loader_role.name
  on_schema {
    schema_name = "\"${snowflake_database.sf_raw_db.name}\".\"${snowflake_schema.landing_zone.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "sch_grant_sf_reporter_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_reporter_role.name
  on_schema {
    schema_name = "\"${snowflake_database.sf_gold_db.name}\".\"${snowflake_schema.analytics.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "sch_grant_raw_sf_transformer_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_transformer_role.name
  on_schema {
    schema_name = "\"${snowflake_database.sf_raw_db.name}\".\"${snowflake_schema.landing_zone.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "sch_grant_gold_sf_transformer_role" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_transformer_role.name
  on_schema {
    schema_name = "\"${snowflake_database.sf_gold_db.name}\".\"${snowflake_schema.analytics.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "wh_grant_sf_loading_wh" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_loader_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.sf_loading_wh.name
  }
}

resource "snowflake_grant_privileges_to_role" "wh_grant_sf_transforming_wh" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_transformer_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.sf_transforming_wh.name
  }
}

resource "snowflake_grant_privileges_to_role" "wh_grant_sf_reporting_wh" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.sf_reporter_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.sf_reporting_wh.name
  }
}

resource "snowflake_grant_privileges_to_role" "user_grant_sf_demo_loader_user" {
  provider   = snowflake.security_admin
  privileges = ["MONITOR"]
  role_name  = snowflake_role.sf_loader_role.name
  on_account_object {
    object_type = "USER"
    object_name = snowflake_user.sf_demo_loader_user.name
  }
}

resource "snowflake_grant_privileges_to_role" "user_grant_sf_demo_transformer_user" {
  provider   = snowflake.security_admin
  privileges = ["MONITOR"]
  role_name  = snowflake_role.sf_transformer_role.name
  on_account_object {
    object_type = "USER"
    object_name = snowflake_user.sf_demo_transformer_user.name
  }
}

resource "snowflake_grant_privileges_to_role" "user_grant_sf_demo_reporter_user" {
  provider   = snowflake.security_admin
  privileges = ["MONITOR"]
  role_name  = snowflake_role.sf_reporter_role.name
  on_account_object {
    object_type = "USER"
    object_name = snowflake_user.sf_demo_reporter_user.name
  }
}

resource "snowflake_role_grants" "grants_sf_loader_role" {
  provider  = snowflake.security_admin
  role_name = snowflake_role.sf_loader_role.name
  users     = [snowflake_user.sf_demo_loader_user.name]
}

resource "snowflake_role_grants" "grants_sf_transformer_role" {
  provider  = snowflake.security_admin
  role_name = snowflake_role.sf_transformer_role.name
  users     = [snowflake_user.sf_demo_transformer_user.name]
}

resource "snowflake_role_grants" "grants_sf_reporter_role" {
  provider  = snowflake.security_admin
  role_name = snowflake_role.sf_reporter_role.name
  users     = [snowflake_user.sf_demo_reporter_user.name]
}