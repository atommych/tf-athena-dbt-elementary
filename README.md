# snowflake-tf-dbt
Demo Code showing Snowflake and AWS Integration with Terraform and dbt

###  Requirements
Terraform Account and Cli:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

AWS Account and Cli:
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Snowflake Account and Cli:
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

    #Install python dependencies
    pip install -r requirements.txt
    
    #Edit file with your credentials
    source setenv.sh