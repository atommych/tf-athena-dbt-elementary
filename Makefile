# Each environment needs to have a specific location because Terraform will store state

build-datalake: setup-env init-datalake apply-datalake

build-all: build-datalake
destroy-all: destroy-datalake

dbt-run-all: dbt-init plant-seeds dbt-run dbt-docs

# -------------------------------------------------------------------------------------------------
# The Data Lake is the base layer S3 bucket and we create as a separate layer that has no
# explicit dependencies.  We manage the dependency with a consistent naming convention.
#
#	${var.prefix}-datalake-${var.environment}
#
init-datalake:
	terraform -chdir=src/terraform/layers/datalake init

plan-datalake:
	terraform -chdir=src/terraform/layers/datalake plan \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars"

apply-datalake:
	cd src/terraform/layers/datalake; terraform apply  \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

clean-s3-bucket:
	aws s3 rm s3://${PREFIX}-datalake-${ENVIRONMENT} --recursive

destroy-datalake: clean-s3-bucket
	cd src/terraform/layers/datalake; terraform destroy \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

# -------------------------------------------------------------------------------------------------
# This is the brew method of installing Terraform for this example
#
install-terraform:
	brew install hashicorp/tap/terraform

setup-env:
	$(source setenv.sh)

install-dbt:
	pip install -r requirements.txt

dbt-init-new:
	cd src/dbt/ && dbt init etl_dw

dbt-init:
	cd src/dbt/ && dbt init --skip-profile-setup etl_dw

# -------------------------------------------------------------------------------------------------
# Run data pipeline
#

#Upload data to S3
plant-seeds:
	aws s3 sync src/dbt/etl_dw/seeds s3://${PREFIX}-datalake-${ENVIRONMENT}/stage/subscription/inputs/ --exclude="*" --include="*.csv"

dbt-run:
	cd src/dbt/etl_dw/ && dbt run

dbt-docs:
	cd src/dbt/etl_dw/ && dbt docs generate




