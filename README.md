# snowflake-tf-dbt
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
    python3 -m venv snowflake 
    source snowflake/bin/activate

    #Install python dependencies
    pip install -r requirements.txt
    
    #Edit file with your credentials
    source setenv.sh

### Build / Run
    #Provide Infrastructure: AWS S3 
    make build-datalake

    #Initialize dbt profile, upload samples to s3, run dbt workflows and generate documentation
    make run-all

  
### Generated Infrastructure
- **AWS S3 Bucket**: ___prefix___-datalake-___env___

 
### Destroy Infrastructure
    #Destroy Infrastructure: AWS S3, AWS Athena, dbt + elementary
    make destroy-all
