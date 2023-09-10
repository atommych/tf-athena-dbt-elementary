#Initialize dbt environment, required variables:
#   account: $SNOWFLAKE_ACCOUNT
#   password: $SNOWFLAKE_PASSWORD
#   user: $SNOWFLAKE_USER
#   role: ACCOUNTADMIN
#   type: snowflake
#   warehouse: TRANSFORMING_WH
#   database: DEV_GOLD_DB
#   schema: analytics
#   threads: 1
init-dbt:
	dbt init etl_dw

init-dbt-existing-profile:
	dbt init --skip-profile-setup etl_dw