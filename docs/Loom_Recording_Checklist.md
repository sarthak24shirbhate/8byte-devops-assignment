# Loom Video Demo Script & Checklist

**Presenter:** Sarthak Shirbhate (DevOps / SRE Engineer)  
**Target Duration:** ~5 Minutes  
**Repository:** [https://github.com/sarthak24shirbhate/8byte-devops-assignment](https://github.com/sarthak24shirbhate/8byte-devops-assignment)  

---

## Screen Recording Walkthrough

### 1. Introduction & Overview (0:00 – 0:45)
- **What to show on screen:** GitHub repository homepage (`README.md` and repo layout).
- **Talking points:**
  - Introduce yourself: *"Hi team, I'm Sarthak Shirbhate, DevOps/SRE engineer. Today I'm walking you through my implementation for the 8Byte.ai assignment."*
  - Briefly summarize the 4 parts implemented: Terraform multi-AZ infrastructure, FastAPI microservice with metrics and health checks, GitHub Actions CI/CD with security scanning and manual approval, and CloudWatch observability.

### 2. Architecture & Networking (0:45 – 1:45)
- **What to show on screen:** Architecture diagram in `README.md` and `terraform/modules/`.
- **Talking points:**
  - Explain the 3-tier perimeter:
    - **Public tier:** 2 public subnets across 2 AZs with Internet Gateway and ALB.
    - **Private compute tier:** ECS Fargate tasks in 2 private subnets, egressing through a NAT Gateway.
    - **Private data tier:** Amazon RDS PostgreSQL 15 in private DB subnets with `publicly_accessible = false` and gp3 encryption.
  - Highlight least-privilege security groups: ALB allows 80/443 -> ECS allows traffic strictly from ALB SG -> RDS allows 5432 strictly from ECS SG.
  - Mention Secrets Manager: DB password generated cryptographically and injected directly into container memory by the ECS Task Execution Role.

### 3. Application & Local Testing (1:45 – 2:30)
- **What to show on screen:** Terminal running `docker-compose up` or `pytest tests/ -v`.
- **Talking points:**
  - Show the FastAPI app in `app/main.py`: structured JSON logging, `/health` endpoint for ALB target group, `/api/v1/metrics` for request rates and latency, and database CRUD.
  - Show the hardened multi-stage `Dockerfile` running as non-root `appuser:10001`.
  - Show passing tests (`6 passed in 0.15s`).

### 4. CI/CD Pipelines in GitHub Actions (2:30 – 3:45)
- **What to show on screen:** GitHub Actions tab with the green workflow run (`CI/CD Build, Security Scan & Multi-Stage Deployment`).
- **Talking points:**
  - Walk through the pipeline stages:
    1. **Test Suite:** Runs flake8 linting, black formatting, and pytest.
    2. **Build & Scan:** Builds Docker container, runs Trivy vulnerability scanner.
    3. **OIDC Auth & ECR:** Keyless authentication using OpenID Connect (no long-lived AWS keys) and image push to ECR with Git SHA tag.
    4. **Staging Deploy:** Rolls out to Staging ECS service and runs automated `/health` smoke test.
    5. **Manual Production Gate:** Shows the GitHub Environment `production` approval gate requiring human sign-off before production rollout.
    6. **Production Deploy:** Deploys the approved image artifact to Production ECS.

### 5. Monitoring, Logging & Dashboards (3:45 – 4:30)
- **What to show on screen:** `terraform/modules/monitoring/main.tf` and `CHALLENGES.md`.
- **Talking points:**
  - Show CloudWatch dashboards: Infrastructure Health (ECS CPU/Memory, ALB traffic, RDS connections) and Application Health (HTTP 2xx/4xx/5xx status codes, latency percentiles p95/p99).
  - Show the 5 CloudWatch metric alarms wired to Amazon SNS for team notifications.

### 6. Wrap Up (4:30 – 5:00)
- **Talking points:**
  - Mention `CHALLENGES.md` where real debugging challenges (like cyclic SG dependencies and OIDC scoping) are documented.
  - Conclude: *"Thank you for your time, and I look forward to discussing the design decisions during our technical round."*
