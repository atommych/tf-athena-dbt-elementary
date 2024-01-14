# Each environment needs to have a specific location because Terraform will store state

build-datalake: setup-env init-datalake apply-datalake

build-all: build-datalake
destroy-all: destroy-datalake

dbt-run-all: dbt-seed dbt-run dbt-docs dbt-test

# -------------------------------------------------------------------------------------------------
# The Data Lake is the base layer S3 bucket and we create as a separate layer that has no
# explicit dependencies.  We manage the dependency with a consistent naming convention.
#
#	${var.prefix}-datalake-${var.environment}
#
# https://github.com/datamesh-architecture/terraform-aws-dataproduct-aws-athena
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

setup-env:
	$(source ./setenv.sh)

install-dbt:
	pip install -r requirements.txt

dbt-deps:
	cd src/dbt/project/ && dbt deps

run-elementary:
	cd src/dbt/project/ && dbt run --select elementary

dbt-init-current:
	cd src/dbt/project/ && dbt init --skip-profile-setup project

dbt-init-new:
	cd src/dbt/project/ && dbt init project

dbt-config: install-dbt dbt-init-current dbt-deps

edr-report:
	cd src/dbt/project/ && edr report

edr-monitor:
	cd src/dbt/project/ && edr monitor

# -------------------------------------------------------------------------------------------------
# Run data pipeline
#

# CITY=braga make call-api
call-api:
	cd  src/lambda/idealista/ && python idealista_export.py --city ${CITY}

#dbt run -s +my_second_dbt_model
dbt-run:
	cd src/dbt/project/ && dbt run

dbt-docs:
	cd src/dbt/project/ && dbt docs generate

dbt-test:
	cd src/dbt/project/ && dbt test

dbt-seed:
	cd src/dbt/project/ && dbt seed

#Upload data to S3
#make up-ext-table FILE=src/dbt/project/seeds/
up-ext-table:
	aws s3 sync ${FILE} "s3://${PREFIX}-datalake-${ENVIRONMENT}/dbt/data/raw/$(shell date +%Y-%m-%d)/" --exclude="*" --include="*.csv"

#make down-exp-query PATH=idealista/porto/homes
down-exp-table:
	aws s3 sync s3://atommych-datalake-dev/export/${PATH} output/${PATH} --exclude="*" --include="*.csv"

#make dbt-load-raw TABLE=raw.idealista_braga_homes
dbt-load-raw:
	cd src/dbt/project/ && dbt run-operation stage_external_sources --args "select: ${TABLE}"