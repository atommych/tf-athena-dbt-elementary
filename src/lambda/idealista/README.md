# Idealista API 

## Description
`idealista_export` is a python script that Calls idealista API and export data to S3.

## Requirements
 - boto3
 - pandas
 - geopy
 - Idealista API Key & Secret

## `idealista_export.py` script running

    usage: 
        idealista_export.py [-h] --city CITY [--date DATE] [--distance DISTANCE] [--country {es,it,pt}] 
                                [--operation {sale,rent}] [--property_type {homes,offices,premises,garages,bedrooms}] 
                                [--order_field ORDER_FIELD] [--s3_bucket S3_BUCKET]
    
    options:
      -h, --help                    show this help message and exit
      --city CITY                   City name
      --date DATE                   Date for execution (yyyy-MM-dd)
      --distance DISTANCE           Max distance from city in meters (ratio)
      --country                     Country to search in : {es,it,pt}
      --operation                   Type of operation : {sale,rent}
      --property_type               Type of property : {homes,offices,premises,garages,bedrooms}
      --order_field ORDER_FIELD     Order field by property type
      --s3_bucket S3_BUCKET         String for the S3 bucket name


## Examples
```
python idealista_export.py --city braga
python idealista_export.py --city braga --s3_bucket atommych-datalake-prod
python idealista_export.py --city porto --operation rent --country pt --distance 1000 --property_type offices
python idealista_export.py --city vigo --operation rent --country es --distance 5000 --property_type homes --order_field ratioeurm2
```