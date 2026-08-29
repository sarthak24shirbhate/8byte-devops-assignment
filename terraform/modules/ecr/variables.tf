variable "project_name" {
  description = "Project name used for naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "max_image_count" {
  description = "The maximum number of images to retain in ECR before lifecycle pruning"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to attach to the ECR repository"
  type        = map(string)
  default     = {}
}
