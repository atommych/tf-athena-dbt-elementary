# Each environment needs to have a specific location because Terraform will store state

# This is the brew method of installing Terraform for this example
install-terraform:
	brew install hashicorp/tap/terraform

install-awscli:
	brew install awscli

setup-env:
	$(shell source ./setenv.sh)

#Make sure to setup-env first
build-all: build-datalake build-dbt-docs dbt-config

build-datalake: setup-env init-datalake apply-datalake
build-dbt-docs: init-host-dbt-docs apply-host-dbt-docs

dbt-run-all: dbt-seed dbt-run dbt-test

deploy-all-docs: dbt-docs deploy-dbt-docs edr-report deploy-edr-report get-dbt-docs-url get-edr-report-url

destroy-all: destroy-dbt-docs delete-work-group destroy-datalake clean-tf-state delete-tf-state

# -------------------------------------------------------------------------------------------------
# The Data Lake is the base layer: S3 bucket + AWS Athena
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

destroy-datalake: clean-s3-bucket
	cd src/terraform/layers/datalake; terraform destroy \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

# -------------------------------------------------------------------------------------------------
# The dbt docs are available at a static website on S3 bucket
#	${var.prefix}-datalake-${var.environment}

init-host-dbt-docs:
	terraform -chdir=src/terraform/layers/host_dbt_docs init

apply-host-dbt-docs:
	cd src/terraform/layers/host_dbt_docs; terraform apply  \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

destroy-dbt-docs: clean-dbt-docs clean-s3-dbt-docs
	cd src/terraform/layers/host_dbt_docs; terraform destroy \
 	-var-file="../../../../environments/${ENVIRONMENT}.tfvars" -auto-approve

# Get the URL for elementary report static website
get-edr-report-url:
	cd src/terraform/layers/host_dbt_docs; terraform output dbt_docs_website_url

# Get the URL for dbt docs static website
get-dbt-docs-url:
	cd src/terraform/layers/host_dbt_docs; terraform output edr_report_website_url

# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# dbt configuration
#
#https://docs.getdbt.com/quickstarts/manual-install?step=3
#https://docs.elementary-data.com/quickstart#install-dbt-package
#https://docs.elementary-data.com/quickstart/generate-report-ui
#https://github.com/dbt-athena/dbt-athena
#https://docs.getdbt.com/docs/core/connect-data-platform/athena-setup

dbt-config: install-dbt dbt-init-current dbt-deps

install-dbt:
	pip install -r requirements.txt

dbt-init-new:
	cd src/dbt/project/ && dbt init project

dbt-init-current:
	cd src/dbt/project/ && dbt init --skip-profile-setup project

dbt-deps:
	cd src/dbt/project/ && dbt deps

# -------------------------------------------------------------------------------------------------
# Run data pipeline
#

# CITY=braga make call-api
call-api:
	cd  src/lambda/idealista/ && python idealista_export.py --city ${CITY}

#make dbt-load-raw TABLE=raw.idealista_braga_homes
dbt-load-raw:
	cd src/dbt/project/ && dbt run-operation stage_external_sources --args "select: ${TABLE}"

dbt-seed:
	cd src/dbt/project/ && dbt seed

#dbt run -s +my_second_dbt_model
dbt-run:
	cd src/dbt/project/ && dbt run

run-elementary:
	cd src/dbt/project/ && dbt run --select elementary

dbt-test:
	cd src/dbt/project/ && dbt test

dbt-docs:
	cd src/dbt/project/ && dbt docs generate

edr-report:
	cd src/dbt/project/ && edr report

edr-monitor:
	cd src/dbt/project/ && edr monitor

install-streamlit:
	cd ../ && git clone https://github.com/atommych/st-idealista.git

# https://atommych-idealista-streamlit.onrender.com/
# Run streamlit locally
# localhost:8501
run-streamlit:
	cd ../st-idealista/ && streamlit run main.py


# -------------------------------------------------------------------------------------------------
# AWS Utils

# Upload data to S3
# make up-ext-table FILE=src/dbt/project/seeds/
up-ext-table:
	aws s3 sync ${FILE} "s3://${PREFIX}-datalake-${ENVIRONMENT}/input/$(shell date +%Y-%m-%d)/" --exclude="*" --include="*.csv"

# Download data from S3 to output folder
# make down-exp-query PATH=idealista/porto/homes
down-exp-table:
	aws s3 sync s3://${PREFIX}-datalake-dev/export/${PATH} output/${PATH} --exclude="*" --include="*.csv"


# Upload dbt-docs static website to s3 bucket
deploy-dbt-docs:
	aws s3 sync src/dbt/project/target s3://${PREFIX}-dbt-docs --delete

# Upload elementary report static website to s3 bucket
deploy-edr-report:
	aws s3 sync src/dbt/project/edr_target s3://${PREFIX}-edr-report --delete

# Clean the main S3 bucket
clean-s3-bucket:
	aws s3 rm s3://${PREFIX}-datalake-${ENVIRONMENT} --recursive

clean-dbt-docs:
	aws s3 rm s3://${PREFIX}-dbt-docs --recursive

clean-s3-dbt-docs:
	aws s3api delete-objects --bucket ${PREFIX}-dbt-docs --delete\
      "$(shell aws s3api list-object-versions \
      --bucket "atommych-dbt-docs" \
      --output=json \
      --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

clean-tf-state:
	aws s3 rm s3://${PREFIX}-terraform-state --recursive

delete-tf-state:
	aws s3 rb s3://${PREFIX}-terraform-state --recursive

delete-work-group:
	aws athena delete-work-group --work-group ${PREFIX}-athena-workgroup-${ENVIRONMENT} --recursive-delete-option
