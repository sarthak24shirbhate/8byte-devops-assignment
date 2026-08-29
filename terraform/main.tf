# ---------------------------------------------------------------------------------------------------------------------
# 1. NETWORKING (VPC, Subnets, Gateways, Route Tables)
# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. SECURITY GROUPS (ALB, ECS, RDS with SG-to-SG least-privilege references)
# ---------------------------------------------------------------------------------------------------------------------
module "security_groups" {
  source = "./modules/security-groups"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  application_port        = var.application_port
  database_port           = 5432
  alb_ingress_cidr_blocks = var.alb_ingress_cidr_blocks
  tags                    = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 3. APPLICATION LOAD BALANCER (Public Facing, Health Checked Target Group)
# ---------------------------------------------------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  application_port      = var.application_port
  health_check_path     = var.health_check_path
  health_check_matcher  = var.health_check_matcher
  certificate_arn       = var.certificate_arn
  tags                  = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. DATABASE (RDS PostgreSQL, DB Subnet Group, AWS Secrets Manager)
# ---------------------------------------------------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  project_name              = var.project_name
  environment               = var.environment
  private_subnet_ids        = module.vpc.private_subnet_ids
  rds_security_group_id     = module.security_groups.rds_security_group_id
  rds_engine                = var.rds_engine
  rds_engine_version        = var.rds_engine_version
  rds_instance_class        = var.rds_instance_class
  rds_allocated_storage     = var.rds_allocated_storage
  rds_max_allocated_storage = var.rds_max_allocated_storage
  database_name             = var.database_name
  database_username         = var.database_username
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  tags                      = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 5. APPLICATION COMPUTE (ECS Fargate Cluster, Task Definition, Service, IAM Roles)
# ---------------------------------------------------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_security_group_id
  target_group_arn      = module.alb.target_group_arn
  application_port      = var.application_port
  container_image       = var.container_image
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  desired_count         = var.desired_count
  log_retention_days    = var.log_retention_days

  db_host       = module.rds.db_instance_address
  db_port       = module.rds.db_instance_port
  db_name       = module.rds.db_name
  db_user       = module.rds.db_username
  db_secret_arn = module.rds.db_secretsmanager_secret_arn

  tags = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 6. CONTAINER REGISTRY (Amazon ECR)
# ---------------------------------------------------------------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 7. CI/CD OIDC ROLE (GitHub Actions Keyless Authentication)
# ---------------------------------------------------------------------------------------------------------------------
module "oidc" {
  source = "./modules/oidc"

  project_name           = var.project_name
  environment            = var.environment
  github_org_repo        = var.github_org_repo
  ecr_repository_arn     = module.ecr.repository_arn
  ecs_cluster_arn        = module.ecs.cluster_arn
  ecs_execution_role_arn = module.ecs.execution_role_arn
  ecs_task_role_arn      = module.ecs.task_role_arn
  tags                   = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 8. OBSERVABILITY & MONITORING (CloudWatch Dashboards, Alarms & SNS Topic)
# ---------------------------------------------------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name            = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  ecs_cluster_name        = module.ecs.cluster_name
  ecs_service_name        = module.ecs.service_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  rds_instance_identifier = module.rds.db_instance_id
  alert_email             = var.alert_email
  tags                    = local.default_tags
}
