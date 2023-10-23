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
    python3 -m venv ../../../env/python/dbt-athena 
    source ../../../env/python/dbt-athena/bin/activate
 
    #Edit file with your credentials and environment variables
    vi setenv.sh
     
    # Setup ~/.dbt/profiles.yml
    #           project:
    #             outputs:
    #               dev:
    #                 database: datalake_catalog
    #                 region_name: eu-west-3
    #                 s3_data_dir: s3://atommych-datalake-dev/data/
    #                 s3_staging_dir: s3://atommych-datalake-dev/stg/
    #                 schema: datalake_dev
    #                 threads: 1
    #                 type: athena
    #             target: dev

    #In case of dbt already config  
    dbt-init
    
    #In case of new environment: 
    make dbt-config

### Build / Run
    #Provide Infrastructure: AWS S3, AWS Athena, AWS Glue 
    make build-datalake

    #Initialize dbt profile, upload samples to s3, run dbt workflows and generate documentation
    make dbt-run-all
  
### Generated Infrastructure
- **AWS S3 Bucket**: ___prefix___-datalake-___env___

 
### Destroy Infrastructure
    #Destroy Infrastructure: AWS S3, AWS Athena, AWS Glue
    make destroy-all
