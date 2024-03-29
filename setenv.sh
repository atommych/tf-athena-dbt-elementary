#!/usr/bin/env bash
# Include private data here
#source ~/.setenv.sh

#Application environment variables
environment="dev"
prefix="atommych"
apikey=""
secret=""

#HardCodedAWSCredentials
#region=
#aws_account_id=
#access_key=
#secret_key=

export PREFIX=$prefix
export ENVIRONMENT=$environment
export IDEALISTA_API_KEY=$apikey
export IDEALISTA_SECRET=$secret

# Set terraform variables
cp environments/env.tfvars.template environments/$environment.tfvars
sed -i '' 's/<environment>/"'$environment'"/g' environments/$environment.tfvars
sed -i '' 's/<prefix>/"'$prefix'"/g' environments/$environment.tfvars
sed -i '' 's/<region>/"'$region'"/g' environments/$environment.tfvars

# Add athena connection in:  ~/.dbt/profiles.yml
cp src/dbt/setup/profiles-template.yml src/dbt/setup/$environment-profiles-template.yml
sed -i '' 's/<environment>/'$environment'/g' src/dbt/setup/$environment-profiles-template.yml
sed -i '' 's/<prefix>/'$prefix'/g' src/dbt/setup/$environment-profiles-template.yml
sed -i '' 's/<region>/'$region'/g' src/dbt/setup/$environment-profiles-template.yml
cat src/dbt/setup/$environment-profiles-template.yml >> ~/.dbt/profiles.yml

python3 -m venv py_atommych_idealista
source py_atommych_idealista/bin/activate

#HardCodedAWSCredentials
#sed -i 's/<region>/"'$region'"/g' environments/$environment.tfvars
#sed -i 's/<aws_account_id>/"'$aws_account_id'"/g' environments/$environment.tfvars
#sed -i 's/<access_key>/"'$access_key'"/g' environments/$environment.tfvars
#sed -i 's/<secret_key>/"'$secret_key'"/g' environments/$environment.tfvars




