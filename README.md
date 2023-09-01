# snowflake-tf-dbt
Demo Code showing Snowflake and AWS Integration with Terraform and dbt.

Terraform guide for snowflake:
https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html

Privileges to customize roles:
https://docs.snowflake.com/en/user-guide/security-access-control-privileges

Architecture based on: 
https://www.getdbt.com/blog/how-we-configure-snowflake/
![Architecture](https://cdn-images-1.medium.com/max/2400/1*FPxDaqugiCChkv5QxsoN7w.png)

###  Requirements
Terraform Account and Cli:
- https://app.terraform.io/public/signup/account
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

AWS Account and Cli:
- https://portal.aws.amazon.com/billing/signup
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Snowflake Account and Cli:
- https://signup.snowflake.com/
- https://docs.snowflake.com/pt/user-guide/snowsql-install-config

### Setup cli credentials
    #Set AWS Access Key ID and AWS Secret Access Key        
    aws configure

    #Check credentials 
    aws configure list
    vi ~/.aws/credentials

### Config a new environment
    #Create new python env 
    python3 -m venv snowflake 
    source snowflake/bin/activate        

    #Install python dependencies
    pip install -r requirements.txt
    
    #Edit file with your credentials
    source setenv.sh

### Build / Run
    #Provide Infrastructure: AWS S3 
    ENVIRONMENT=dev make build-datalake

    #Provide Infrastructure: Snowflake Warehouses, Database, Schemas, Users, Roles and Grants
    ENVIRONMENT=dev make build-snowflake-db
    
### Generated Infrastructure

- **Connection**: ___account.region___.snowflakecomputing.com
- **Databases**: DEV_RAW_SGA_DB, DEV_GOLD_SGA_DB
- **Schemas**: LANDING_ZONE, ANALYTICS
- **Warehouses**: LANDING_ZONE, TRANSFORMING_WH, REPORTING_WH
- **Roles**: PUBLIC, LOADER_ROLE, TRANSFORMER_ROLE, REPORTER_ROLE
- **Users**: admin, LOADER_USER, TRANSFORMER_USER, REPORTER_USER
- **AWS S3 Bucket**: ___prefix___-datalake-___env___

### Destroy Infrastructure
    #Destroy Infrastructure: AWS S3, Snowflake Warehouses, Database, Schemas, Users, Roles and Grants
    ENVIRONMENT=dev make destroy-all
