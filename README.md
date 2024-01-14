# tf-athena-dbt-elementary
Demo Code showing Terraform, AWS Athena, dbt and elementary.

###  Requirements
Terraform Account and Cli:
- https://app.terraform.io/public/signup/account
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

AWS Account and Cli:
- https://portal.aws.amazon.com/billing/signup
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


### Setup AWS credentials
    #Set AWS Access Key ID and AWS Secret Access Key        
    aws configure

    #Check credentials 
    aws configure list
    vi ~/.aws/credentials
  
    #Othewise use #HardCodedAWSCredentials

### Config a new environment
    #Create new python env 
    python3 -m venv dbt-athena 
    source dbt-athena/bin/activate
 
    #Edit file with your credentials and environment variables
    vi setenv.sh

     
### Build Infrastructure
- https://www.datamesh-architecture.com/
- https://github.com/datamesh-architecture/terraform-aws-dataproduct-aws-athena
  - **AWS S3 Bucket**
  - **AWS Athena** 
  - **AWS Glue**
  - **AWS Lambda**

   
    make build-datalake

### Config dbt environment
- https://docs.getdbt.com/docs/core/connect-data-platform/athena-setup


    #Config dbt environment: 
    make dbt-config

    #Upload sample to s3, run dbt and generate documentation
    make dbt-run-all 

    #Run idealista API export
    CITY=lisboa make call-api
    
    #Run raw table ingestion
    make dbt-load-raw TABLE=raw.idealista_lisboa_sale_homes

### Destroy Infrastructure
    #Destroy Infrastructure: AWS S3, AWS Athena, AWS Glue
    make destroy-all
