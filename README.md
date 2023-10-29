# tf-athena-dbt-elementary
Demo Code showing Terraform, AWS Athena, dbt and elementary.

###  Requirements
Terraform Account and Cli:
- https://app.terraform.io/public/signup/account
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

AWS Account and Cli:
- https://portal.aws.amazon.com/billing/signup
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


### Setup cli credentials
    #Set AWS Access Key ID and AWS Secret Access Key        
    aws configure

    #Check credentials 
    aws configure list
    vi ~/.aws/credentials


### Config a new environment
    #Create new python env 
    python3 -m venv dbt-athena 
    source dbt-athena/bin/activate
 
    #Edit file with your credentials and environment variables
    vi setenv.sh

     
### Build Infrastructure
- **AWS S3 Bucket**
- **AWS Athena** 
- **AWS Glue**

   
    make build-datalake


## Config dbt environment 
- https://docs.getdbt.com/docs/core/connect-data-platform/athena-setup

      #Set your athena connection in:  ~/.dbt/profiles.yml
      #        tf-athena-dbt-elementary:
      #          outputs:
      #            dev:
      #              database: AwsDataCatalog
      #              region_name: eu-west-3
      #              s3_data_dir: s3://atommych-datalake-dev/data/
      #              s3_staging_dir: s3://atommych-datalake-dev/stage/
      #              schema: datalake_dev
      #              threads: 5
      #              type: athena
      #          target: dev


### Run dbt project

    #In case of new environment: 
    make dbt-config

    #In case of dbt already config  
    make dbt-init

    #Initialize dbt profile, upload samples to s3, run dbt workflows and generate documentation
    make dbt-run-all 


### Destroy Infrastructure
    #Destroy Infrastructure: AWS S3, AWS Athena, AWS Glue
    make destroy-all
