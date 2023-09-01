variable "datalake_storage" {
  description = "The Data Lake Storage "
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment"
  type = string
}

variable "prefix" {
  description = "A unique prefix for the project."
  type        = string
}

variable "snowflake_database" {
  description = "The database name"
  type        = string
  default     = null
}