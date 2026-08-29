# Technical Assignment Submission Notes

**Candidate:** Sarthak Shirbhate  
**Role:** Senior DevOps / SRE Engineer  
**Repository:** [https://github.com/sarthak24shirbhate/8byte-devops-assignment](https://github.com/sarthak24shirbhate/8byte-devops-assignment)  
**Target:** 8Byte.ai DevOps Engineer Assignment  

---

## Deliverables Checklist

| Requirement | Implementation Location | Notes |
| :--- | :--- | :--- |
| **VPC with Public/Private Subnets** | `terraform/modules/vpc/` | Multi-AZ (AZ1, AZ2), 2 public subnets, 2 private subnets, NAT Gateway, Route Tables |
| **ECS Fargate Hosting** | `terraform/modules/ecs/` | Fargate cluster, task definition, service, IAM execution & task roles |
| **RDS PostgreSQL Database** | `terraform/modules/rds/` | PostgreSQL 15.7 in private DB subnets, gp3 encryption, automated backups |
| **Security Groups** | `terraform/modules/security-groups/` | Least-privilege rules: ALB -> ECS -> RDS |
| **Load Balancer** | `terraform/modules/alb/` | Internet-facing ALB, IP target group, `/health` endpoint checks |
| **Variables & State Management** | `terraform/variables.tf`, `terraform/bootstrap/` | Input validation, S3 backend with DynamoDB locking |
| **CI/CD Pipelines** | `.github/workflows/` | PR testing, Trivy scan, OIDC auth, ECR push, Staging deploy, Manual Prod approval |
| **Monitoring & Dashboards** | `terraform/modules/monitoring/` | 2 CloudWatch dashboards (Infra + App Health), 5 alarms, SNS alerts |
| **Logging** | `terraform/modules/ecs/` | Centralized CloudWatch log group with 7-day retention |
| **Documentation & Runbook** | `README.md`, `CHALLENGES.md` | Architecture, local setup, runbook, cost optimization, and real challenges |
| **Challenges PDF** | `docs/8Byte_DevOps_Assignment_Challenges_Sarthak_Shirbhate.pdf` | Formatted PDF deliverable |
| **Loom Demo Script** | `docs/Loom_Recording_Checklist.md` | Step-by-step presentation walkthrough |
