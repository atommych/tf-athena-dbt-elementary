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

variable "landing_zone_schema" {
  description = "The database schema for the landing zone data"
  type        = string
  default     = null
}

variable "analytics_schema" {
  description = "The database schema for the analytics data"
  type        = string
  default     = null
}