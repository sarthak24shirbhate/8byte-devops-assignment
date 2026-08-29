# ---------------------------------------------------------------------------------------------------------------------
# GENERAL CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to deploy infrastructure in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming conventions and resource tagging"
  type        = string
  default     = "8byte"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Team or individual owner tag for the infrastructure resources"
  type        = string
  default     = "sarthak-shirbhate"
}

variable "github_org_repo" {
  description = "GitHub repository in 'owner/repo' format for OIDC role trust policy"
  type        = string
  default     = "sarthak24shirbhate/8byte-devops-assignment"
}

variable "alert_email" {
  description = "Optional email address to receive CloudWatch SNS alarm notifications"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING / VPC CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (minimum 2 in distinct AZs for ALB)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required for High Availability."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (minimum 2 in distinct AZs for ECS and RDS)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs are required for High Availability."
  }
}

variable "availability_zones" {
  description = "Optional list of availability zones. If empty, the first 2 available AZs in the region will be selected dynamically."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway across private subnets for cost optimization in dev/test (set to false for production multi-AZ HA)"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER & SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------
variable "application_port" {
  description = "The port on which the container application listens"
  type        = number
  default     = 8000
}

variable "alb_ingress_cidr_blocks" {
  description = "Allowed ingress CIDR blocks for the ALB (default 0.0.0.0/0)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "health_check_path" {
  description = "HTTP path queried by ALB for target health checks"
  type        = string
  default     = "/health"
}

variable "health_check_matcher" {
  description = "HTTP response codes to consider healthy"
  type        = string
  default     = "200-399"
}

variable "certificate_arn" {
  description = "Optional ACM SSL/TLS certificate ARN for ALB HTTPS listener"
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS FARGATE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
variable "container_image" {
  description = "Docker/OCI container image to deploy"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:alpine"
}

variable "container_cpu" {
  description = "Fargate vCPU units allocated to task (256 = 0.25 vCPU, 512 = 0.5 vCPU, 1024 = 1.0 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate memory allocated to task in MiB (512, 1024, 2048)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of running ECS task instances"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch application logs in days"
  type        = number
  default     = 7
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS POSTGRESQL CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
variable "rds_engine" {
  description = "RDS database engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.7"
}

variable "rds_instance_class" {
  description = "Database instance compute class (cost-conscious db.t3.micro for dev/assignment)"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Upper storage auto-scaling limit in GB"
  type        = number
  default     = 50
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "appdb"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.database_name))
    error_message = "Database name must contain only alphanumeric characters and underscores."
  }
}

variable "database_username" {
  description = "Master database administrator username"
  type        = string
  default     = "appadmin"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.database_username))
    error_message = "Database username must contain only alphanumeric characters and underscores."
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain automated RDS backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection on RDS (recommended false for dev/sandbox, true for prod)"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final DB snapshot on terraform destroy (true for dev/test)"
  type        = bool
  default     = true
}
