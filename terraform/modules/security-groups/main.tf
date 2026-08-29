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
# 1. APPLICATION LOAD BALANCER SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-sg-"
  description = "Security group for public-facing Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
      Role = "LoadBalancer"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow inbound HTTP from specified CIDRs (default 0.0.0.0/0)
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidr_blocks
  description       = "Allow inbound HTTP traffic from Internet"
}

# Allow inbound HTTPS from specified CIDRs
resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidr_blocks
  description       = "Allow inbound HTTPS traffic from Internet"
}

# Allow outbound traffic to ECS tasks on application port
resource "aws_security_group_rule" "alb_to_ecs_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  from_port                = var.application_port
  to_port                  = var.application_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow outbound traffic from ALB to ECS tasks on application port"
}


# ---------------------------------------------------------------------------------------------------------------------
# 2. ECS FARGATE APPLICATION SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "ecs" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-sg-"
  description = "Security group for ECS Fargate application tasks (Private Subnets)"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-sg"
      Role = "Application"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Inbound ONLY from ALB security group on application port
resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs.id
  from_port                = var.application_port
  to_port                  = var.application_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow inbound traffic strictly from ALB security group"
}

# Outbound egress to Internet (via NAT Gateway) for image pull, Secrets Manager, CloudWatch, and DB
resource "aws_security_group_rule" "ecs_all_egress" {
  type              = "egress"
  security_group_id = aws_security_group.ecs.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound traffic for ECR/Docker image pulling, Secrets Manager, CloudWatch, and RDS connectivity"
}


# ---------------------------------------------------------------------------------------------------------------------
# 3. RDS POSTGRESQL DATABASE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  description = "Security group for RDS PostgreSQL Database (Private Subnets)"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
      Role = "Database"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Inbound ONLY from ECS security group on PostgreSQL port (5432)
resource "aws_security_group_rule" "rds_ingress_from_ecs" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds.id
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow PostgreSQL access strictly from ECS application tasks"
}
