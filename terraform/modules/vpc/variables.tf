variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (minimum 2 for multi-AZ ALB)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required for High Availability."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (minimum 2 for ECS and RDS multi-AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs are required for High Availability."
  }
}

variable "availability_zones" {
  description = "Optional list of availability zones to use. If empty, AZs will be dynamically fetched from the AWS region."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Deploy a single NAT Gateway across private subnets to optimize costs for dev/interview environments (set to false for production HA)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}
