# snowflake-tf-dbt
Demo Code showing Snowflake and AWS Integration with Terraform and dbt

Architecture based on: https://www.getdbt.com/blog/how-we-configure-snowflake/
![Architecture](https://cdn-images-1.medium.com/max/2400/1*FPxDaqugiCChkv5QxsoN7w.png)

Terraform guide for snowflake:
https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html

Privileges to customize the roles:
https://docs.snowflake.com/en/user-guide/security-access-control-privileges

###  Requirements
Terraform Account and Cli:
https://app.terraform.io/public/signup/account
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

AWS Account and Cli:
https://portal.aws.amazon.com/billing/signup
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Snowflake Account and Cli:
https://signup.snowflake.com/
https://docs.snowflake.com/pt/user-guide/snowsql-install-config


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

### Run code
    
    #Provide Infrastructure: AWS S3 
    ENVIRONMENT=dev make build-datalake

    #Provide Infrastructure: Snowflake Warehouses, Database and Schemas (+3 Demo: Users, Roles and Grants)
    ENVIRONMENT=dev make build-snowflake-db
    
    #Destroy Infrastructure: AWS S3, Snowflake Warehouses, Database and Schemas
    ENVIRONMENT=dev make destroy-all