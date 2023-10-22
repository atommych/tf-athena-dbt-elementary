# Include private data here
#source ~/.setenv.sh

#Application environment variables
environment="dev"
prefix="atommych"
region="eu-west-3"
aws_account_id=<###>
access_key="<###>"
secret_key="<###>"


export PREFIX=$prefix
export ENVIRONMENT=$environment

cp environments/env.tfvars.template environments/$environment.tfvars
sed -i 's/<environment>/"'$environment'"/g' environments/$environment.tfvars
sed -i 's/<prefix>/"'$prefix'"/g' environments/$environment.tfvars
sed -i 's/<region>/"'$region'"/g' environments/$environment.tfvars
sed -i 's/<aws_account_id>/"'$aws_account_id'"/g' environments/$environment.tfvars
sed -i 's/<access_key>/"'$access_key'"/g' environments/$environment.tfvars
sed -i 's/<secret_key>/"'$secret_key'"/g' environments/$environment.tfvars




