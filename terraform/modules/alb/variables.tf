variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB target group will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "application_port" {
  description = "Port on which the target ECS containers receive traffic"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP path for ALB target group health checks"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP response codes to consider healthy"
  type        = string
  default     = "200-399"
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive health check successes required before considering an unhealthy target healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 3
}

variable "certificate_arn" {
  description = "Optional ARN of an ACM SSL/TLS certificate for HTTPS listener"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to ALB resources"
  type        = map(string)
  default     = {}
}
