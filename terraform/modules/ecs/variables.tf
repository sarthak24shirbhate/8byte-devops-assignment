variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register ECS tasks with"
  type        = string
}

variable "application_port" {
  description = "Port on which the application container listens"
  type        = number
  default     = 80
}

variable "container_image" {
  description = "Container image URL (can be public ECR/Docker Hub or private ECR repo supplied later by CI/CD)"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:alpine"
}

variable "container_cpu" {
  description = "Fargate CPU units (256 = 0.25 vCPU, 512 = 0.5 vCPU, 1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate Memory in MiB (512, 1024, 2048)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS task instances"
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs in days"
  type        = number
  default     = 7
}

variable "db_host" {
  description = "Database hostname/endpoint to pass as environment variable"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Database port to pass as environment variable"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name to pass as environment variable"
  type        = string
  default     = ""
}

variable "db_user" {
  description = "Database username to pass as environment variable"
  type        = string
  default     = ""
}

variable "db_secret_arn" {
  description = "Secrets Manager Secret ARN for database credentials"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to ECS resources"
  type        = map(string)
  default     = {}
}
