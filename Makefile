# Each environment needs to have a specific location because Terraform will store state

build-datalake: init-datalake apply-datalake
build-snowflake-db: init-snowflake-db apply-snowflake-db

build-all: build-datalake build-snowflake-db
destroy-all: destroy-snowflake-db destroy-datalake

# -------------------------------------------------------------------------------------------------
# The Data Lake is the base layer S3 bucket and we create as a separate layer that has no
# explicit dependencies.  We manage the dependency with a consistent naming convention.
#
#	${var.prefix}-datalake-${var.environment}
#
init-datalake:
	terraform -chdir=src/terraform/layers/datalake init

plan-datalake:
	terraform -chdir=src/terraform/layers/datalake plan -var="aws_account_id=${AWS_ACCOUNT_ID}" \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars"

apply-datalake:
	terraform -chdir=src/terraform/layers/datalake apply  -var="aws_account_id=${AWS_ACCOUNT_ID}" \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

clean-s3-bucket:
	aws s3 rm s3://${PREFIX}-datalake-${ENVIRONMENT} --recursive

destroy-datalake: clean-s3-bucket
	terraform -chdir=src/terraform/layers/datalake destroy  -var="aws_account_id=${AWS_ACCOUNT_ID}" \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

# -------------------------------------------------------------------------------------------------
# The Snowflake database is the base level database and is again created as a layer to avoid
# dependencies.  We also create the base schema skeleton in this layer.
#
# We manage the database with a naming convention:
#
#	upper("${var.environment}_CATALOG")
#
init-snowflake-db:
	terraform -chdir=src/terraform/layers/snowflake-db init

plan-snowflake-db:
	terraform -chdir=src/terraform/layers/snowflake-db plan -var-file="../../../../environments/${ENVIRONMENT}.tfvars"

apply-snowflake-db:
	terraform -chdir=src/terraform/layers/snowflake-db apply -var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

destroy-snowflake-db:
	terraform -chdir=src/terraform/layers/snowflake-db destroy -var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

# -------------------------------------------------------------------------------------------------
# This is the brew method of installing Terraform for this example
#
install-terraform:
	brew install hashicorp/tap/terraform

install-dbt:
	pip install -r requirements.txt