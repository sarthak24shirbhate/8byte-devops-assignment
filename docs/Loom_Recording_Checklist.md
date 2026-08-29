# Loom Video Demonstration Checklist & Presentation Script

**Candidate:** Sarthak Shirbhate  
**Role:** Senior DevOps / SRE Engineer  
**Assignment:** 8Byte.ai DevOps Engineer Technical Assignment  
**Target Video Duration:** 5–7 Minutes  

---

## 1. Loom Recording Flow & Checklist

| # | Step / Topic | Duration | Key Talking Points & Screen Actions |
| :- | :--- | :--- | :--- |
| **1** | **Introduction & Repository** | 0:30 | • Introduce yourself (Sarthak Shirbhate, DevOps/SRE Engineer).<br/>• Show GitHub repository: `github.com/sarthak24shirbhate/8byte-devops-assignment`.<br/>• Highlight professional folder layout (`app/`, `terraform/`, `.github/workflows/`, `docs/`). |
| **2** | **Architecture Overview** | 1:00 | • Open `README.md` Mermaid diagram.<br/>• Explain the 3-Tier Multi-AZ architecture (Public ALB -> Private ECS Fargate -> Private RDS PostgreSQL).<br/>• Emphasize zero-trust security groups (ALB SG -> ECS SG -> RDS SG). |
| **3** | **Application & Containerization** | 0:45 | • Show `app/main.py` (FastAPI with structured JSON logging, `/health`, `/api/v1/metrics`, DB CRUD).<br/>• Show `Dockerfile` (multi-stage, non-root `appuser:10001`, minimal attack surface).<br/>• Show passing unit/integration tests (`pytest tests/ -v`). |
| **4** | **Terraform Infrastructure (IaC)** | 1:15 | • Walk through `terraform/` modular structure (`vpc`, `security-groups`, `alb`, `ecs`, `rds`, `ecr`, `oidc`, `monitoring`).<br/>• Show remote state bootstrap in `terraform/bootstrap/` (encrypted S3 + DynamoDB locking).<br/>• Highlight zero plaintext passwords via AWS Secrets Manager & dynamic IAM execution role resolution. |
| **5** | **CI/CD Pipeline & GitHub Actions** | 1:30 | • Show `.github/workflows/pr-validation.yml` (Linting + Pytest + Trivy security scan + Terraform validate).<br/>• Show `.github/workflows/deploy.yml` (OIDC auth -> ECR push -> Staging deploy -> Smoke test -> **Manual Approval Gate** -> Production deploy).<br/>• Show GitHub Environment `production` configuration with review protection. |
| **6** | **Monitoring, Logging & Dashboards** | 1:00 | • Show `modules/monitoring/main.tf` CloudWatch dashboards:<br/>  - *Dashboard 1:* Infrastructure Health (ECS CPU/Memory, ALB traffic, RDS IOPS/storage).<br/>  - *Dashboard 2:* Application Health (Request rates, p95/p99 latency, 2xx/4xx/5xx status).<br/>• Show CloudWatch Alarms & SNS alert integration. |
| **7** | **Conclusion & Key Learnings** | 0:30 | • Open `CHALLENGES.md` (highlighting real engineering resolutions like OIDC IAM scoping, SG cyclic dependency prevention, and DB lifespan fixtures).<br/>• Summarize readiness for production roadmap. |

---

## 2. Word-for-Word Speaking Script

### Introduction (0:00 - 0:30)
> *"Hello 8Byte.ai hiring team. My name is Sarthak Shirbhate, and today I am excited to walk you through my complete, end-to-end implementation of the DevOps Engineer Technical Assignment.*
>
> *I designed and built this project from the ground up as a production-grade, highly available, and cost-conscious AWS platform orchestrated entirely via Terraform and automated with GitHub Actions CI/CD."*

### Architecture & Security (0:30 - 1:30)
> *"Looking at the architecture diagram in the repository README, the design enforces strict network isolation across two Availability Zones in AWS.*
>
> *At the public ingress tier, we have an Application Load Balancer in public subnets that handles SSL/TLS termination and public web traffic. Crucially, our application compute—running on serverless ECS Fargate—and our data tier—running Amazon RDS PostgreSQL 15—are deployed strictly into private subnets with no public IP addresses or internet routing.*
>
> *Our security groups enforce a zero-trust chain: the ALB accepts traffic from the Internet, the ECS security group accepts traffic strictly from the ALB security group, and the RDS security group accepts PostgreSQL port 5432 strictly from the ECS security group. Database master credentials are dynamically generated, stored in AWS Secrets Manager, and retrieved in-memory by the ECS Task Execution Role without exposing plaintext passwords in Git, variables, or outputs."*

### Application & Testing (1:30 - 2:15)
> *"For the application workload, I built a lightweight Python FastAPI microservice equipped with structured JSON logging, correlation IDs, an ALB health check endpoint at `/health`, an operational metrics endpoint at `/api/v1/metrics`, and CRUD endpoints for database persistence.*
>
> *The application is containerized using a multi-stage, non-root Dockerfile running under an unprivileged system user. Running `pytest tests/` executes our 6 unit and integration test cases covering API contracts, latency headers, and database workflows with 100% pass rate."*

### Infrastructure-as-Code & State Management (2:15 - 3:30)
> *"The Terraform codebase is structured into 8 cohesive modules. We separated the state bootstrap into a dedicated `bootstrap` module to provision an AES-256 encrypted, versioned S3 bucket and a DynamoDB table for distributed state locking before initializing root infrastructure.*
>
> *Running `terraform validate` confirms zero errors across all modules. We parameterized a single NAT Gateway toggle for cost-saving in dev while keeping multi-AZ NAT support for production."*

### CI/CD Automation (3:30 - 4:45)
> *"Our deployment automation uses two GitHub Actions workflows:*
> 1. *First, `pr-validation.yml` triggers on every pull request, executing Black and Flake8 linting, Pytest test suites, Trivy dependency scans, and Terraform validation.*
> 2. *Second, on merge to main, `deploy.yml` builds the Docker container, executes Trivy container vulnerability scanning, authenticates to AWS keylessly via OpenID Connect (OIDC), pushes the versioned image to Amazon ECR, and deploys to our Staging ECS cluster.*
>
> *After automated smoke testing verifies the Staging ALB `/health` endpoint, the workflow pauses at a protected GitHub Environment gate requiring manual production approval before rolling the exact same image artifact out to Production."*

### Monitoring, Logging & Conclusion (4:45 - 5:30)
> *"For observability, we provisioned centralized CloudWatch logging for container output and ALB access logs, alongside two dedicated CloudWatch Dashboards: one for Infrastructure Platform Health and one for Application Request Rates, Latency Percentiles, and HTTP Status Codes. Critical alarms trigger alerts to an Amazon SNS topic.*
>
> *All real implementation challenges, root causes, and learnings are detailed in `CHALLENGES.md`. Thank you for reviewing this project, and I look forward to discussing the architecture in our technical interview!"*
