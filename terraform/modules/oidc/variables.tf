variable "project_name" {
  description = "Project name used for naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "github_org_repo" {
  description = "GitHub organization/repository in format 'owner/repo' allowed to assume this IAM role"
  type        = string
  default     = "sarthak24shirbhate/8byte-devops-assignment"
}

variable "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "The ARN of the ECS Cluster"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}

variable "tags" {
  description = "Tags to attach to IAM resources"
  type        = map(string)
  default     = {}
}
