variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "application_port" {
  description = "The port on which the ECS application container listens"
  type        = number
  default     = 80
}

variable "database_port" {
  description = "The port on which the RDS PostgreSQL database listens"
  type        = number
  default     = 5432
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the Application Load Balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags to apply to security groups"
  type        = map(string)
  default     = {}
}
