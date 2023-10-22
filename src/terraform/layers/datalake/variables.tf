variable "region" {
  description = "AWS specific region"
  type        = string
  default     = "eu-west-3"
}

variable "prefix" {
  description = "A unique prefix for the project."
  type        = string
}

variable "environment" {
  description = "The environment for the project"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "aws" {
  type = object({
    region     = string
    access_key = string
    secret_key = string
  })
  sensitive = true
  description = "AWS related information and credentials"
}