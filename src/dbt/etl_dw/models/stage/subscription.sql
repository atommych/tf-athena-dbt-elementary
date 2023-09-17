SELECT 
   metadata$filename, 
   metadata$file_row_number
    ,t.$1 as contract_id
    ,t.$2 as created_at
    ,t.$3 as tenant_id
    ,t.$4 as tamedia_id
    ,t.$5 as valid_from
    ,t.$6 as valid_to
    ,t.$7 as facturaperiode
    ,t.$8 as is_daily_pass
    ,t.$9 as subscription_class
    ,t.$10 as subscription_status
    ,t.$11 as next_billing_date
    ,t.$12 as is_auto_renew
    ,t.$13 as product_id
FROM @DEV_RAW_DB.LANDING_ZONE.SUBSCRIPTION_STAGE t