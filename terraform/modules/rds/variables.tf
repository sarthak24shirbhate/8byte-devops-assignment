variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS DB subnet group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID allowing access to RDS (from ECS only)"
  type        = string
}

variable "rds_engine" {
  description = "The database engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "The database engine version"
  type        = string
  default     = "15.7"
}

variable "rds_instance_class" {
  description = "The instance type of the RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "The upper limit in gigabytes to which Amazon RDS can automatically scale the storage"
  type        = number
  default     = 50
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
  default     = "appdb"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.database_name))
    error_message = "Database name must contain only alphanumeric characters and underscores."
  }
}

variable "database_username" {
  description = "Master username for the database"
  type        = string
  default     = "appadmin"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.database_username))
    error_message = "Database username must contain only alphanumeric characters and underscores."
  }
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted (true for dev/test)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to RDS resources"
  type        = map(string)
  default     = {}
}
