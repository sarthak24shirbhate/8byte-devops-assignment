locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS DB SUBNET GROUP (Private Subnets)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "rds" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  description = "Database subnet group spanning private subnets for ${var.project_name} ${var.environment}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# SECRETS MANAGEMENT (Auto-generated password & AWS Secrets Manager)
# ---------------------------------------------------------------------------------------------------------------------

# Generate a strong cryptographically secure password
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create a secret in Secrets Manager to store DB connection details
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-"
  description             = "Master credentials for ${var.project_name} ${var.environment} PostgreSQL database"
  recovery_window_in_days = 0

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = var.rds_engine
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = var.database_name
    username = var.database_username
    password = random_password.db_password.result
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS POSTGRESQL INSTANCE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_instance" "postgres" {
  identifier                  = "${var.project_name}-${var.environment}-postgres"
  engine                      = var.rds_engine
  engine_version              = var.rds_engine_version
  instance_class              = var.rds_instance_class
  allocated_storage           = var.rds_allocated_storage
  max_allocated_storage       = var.rds_max_allocated_storage
  storage_type                = "gp3"
  storage_encrypted           = true
  publicly_accessible         = false # Strictly isolated to private subnets
  db_subnet_group_name        = aws_db_subnet_group.rds.name
  vpc_security_group_ids      = [var.rds_security_group_id]
  db_name                     = var.database_name
  username                    = var.database_username
  password                    = random_password.db_password.result
  backup_retention_period     = var.backup_retention_period
  backup_window               = "03:00-04:00"
  maintenance_window          = "Sun:04:30-Sun:05:30"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-postgres"
    }
  )

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}
