# Each environment needs to have a specific location because Terraform will store state

build-datalake: setup-env init-datalake apply-datalake

build-all: build-datalake
destroy-all: destroy-datalake

dbt-run-all: plant-seeds dbt-run dbt-docs

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

# -------------------------------------------------------------------------------------------------
# dbt configuration
#
#https://docs.getdbt.com/quickstarts/manual-install?step=3
#https://docs.elementary-data.com/quickstart#install-dbt-package
#https://docs.elementary-data.com/quickstart/generate-report-ui
#https://github.com/dbt-athena/dbt-athena
#https://docs.getdbt.com/docs/core/connect-data-platform/athena-setup
#~/.dbt/profiles.yml
#    project:
#      outputs:
#        dev:
#          database: datalake_catalog
#          region_name: eu-west-3
#          s3_data_dir: s3://atommych-datalake-dev/data/
#          s3_staging_dir: s3://atommych-datalake-dev/stg/
#          schema: datalake_dev
#          threads: 1
#          type: athena
#      target: dev

setup-env:
	$(source setenv.sh)


install-dbt:
	pip install -r requirements.txt

dbt-deps:
	cd src/dbt/project/ && dbt deps

dbt-elementary:
	cd src/dbt/project/ && dbt run --select elementary

dbt-test:
	cd src/dbt/project/ && dbt test

dbt-report:
	cd src/dbt/project/ && edr report

dbt-init-current:
	cd src/dbt/project/ && dbt init --skip-profile-setup project

dbt-init-new:
	cd src/dbt/project/ && dbt init project

dbt-init: dbt-init-current dbt-deps dbt-elementary dbt-test dbt-report

dbt-config: install-dbt dbt-init-new dbt-deps dbt-elementary dbt-test dbt-report
# -------------------------------------------------------------------------------------------------
# Run data pipeline
#

#Upload data to S3
plant-seeds:
	aws s3 sync src/dbt/project/seeds s3://${PREFIX}-datalake-${ENVIRONMENT}/dbt/stg/inputs/ --exclude="*" --include="*.csv"

dbt-run:
	cd src/dbt/project/ && dbt run

dbt-docs:
	cd src/dbt/project/ && dbt docs generate




