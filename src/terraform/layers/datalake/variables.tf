variable "prefix" {
  description = "A unique prefix for the project."
  type        = string
}

variable "environment" {
  description = "The environment for the project"
  type        = string
}

#HardCodedAWSCredentials
#variable "region" {
#  description = "AWS specific region"
#  type        = string
#  default     = "eu-west-3"
#}

#variable "aws_account_id" {
#  description = "The AWS account ID"
#  type        = string
#}