variable "project_name" {
  description = "Project name used for naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS Cluster Name to monitor"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS Service Name to monitor"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN Suffix for CloudWatch metrics dimension (app/name/id)"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN Suffix for CloudWatch metrics dimension (targetgroup/name/id)"
  type        = string
}

variable "rds_instance_identifier" {
  description = "RDS DB Instance Identifier to monitor"
  type        = string
}

variable "alert_email" {
  description = "Optional email address to subscribe to CloudWatch SNS alert notifications"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to attach to monitoring resources"
  type        = map(string)
  default     = {}
}
