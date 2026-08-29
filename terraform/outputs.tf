# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the primary VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs where ALB and NAT Gateways reside"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks and RDS instances reside"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway attached to the VPC"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_public_ips" {
  description = "Public IP(s) assigned to NAT Gateway(s)"
  value       = module.vpc.nat_gateway_public_ips
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "alb_security_group_id" {
  description = "Security Group ID for Application Load Balancer"
  value       = module.security_groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "Security Group ID for ECS Fargate Tasks"
  value       = module.security_groups.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "Security Group ID for RDS Database"
  value       = module.security_groups.rds_security_group_id
}

# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = module.alb.target_group_arn
}

output "http_url" {
  description = "HTTP URL to access the deployed application"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_access_logs_bucket" {
  description = "The name of the S3 bucket created for ALB access logs"
  value       = module.alb.alb_access_logs_bucket
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS FARGATE OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = module.ecs.task_definition_arn
}

output "ecs_execution_role_arn" {
  description = "ARN of the IAM Execution Role (used for CI/CD integrations and permissions)"
  value       = module.ecs.execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the IAM Task Role"
  value       = module.ecs.task_role_arn
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group for container logs"
  value       = module.ecs.log_group_name
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS DATABASE OUTPUTS (NO SENSITIVE PASSWORDS EXPOSED)
# ---------------------------------------------------------------------------------------------------------------------
output "rds_identifier" {
  description = "The identifier of the RDS PostgreSQL database"
  value       = module.rds.db_instance_id
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS PostgreSQL database (address:port)"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "The hostname/address of the RDS PostgreSQL database"
  value       = module.rds.db_instance_address
}

output "rds_port" {
  description = "The port on which the RDS PostgreSQL database accepts connections"
  value       = module.rds.db_instance_port
}

output "database_name" {
  description = "The default database name configured in RDS"
  value       = module.rds.db_name
}

output "database_username" {
  description = "The master username configured for RDS (password is stored securely in Secrets Manager)"
  value       = module.rds.db_username
}

output "db_credentials_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret storing database credentials"
  value       = module.rds.db_secretsmanager_secret_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# ECR & CI/CD OIDC OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "ecr_repository_url" {
  description = "The URL of the Amazon ECR repository for container images"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "The name of the Amazon ECR repository"
  value       = module.ecr.repository_name
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM Role assumed by GitHub Actions via OIDC"
  value       = module.oidc.github_actions_role_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# MONITORING & OBSERVABILITY OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "sns_alerts_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alerts"
  value       = module.monitoring.sns_alerts_topic_arn
}

output "infrastructure_dashboard_name" {
  description = "The name of the Infrastructure CloudWatch Dashboard"
  value       = module.monitoring.infrastructure_dashboard_name
}

output "application_dashboard_name" {
  description = "The name of the Application CloudWatch Dashboard"
  value       = module.monitoring.application_dashboard_name
}
