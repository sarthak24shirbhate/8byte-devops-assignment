# 8Byte.ai DevOps Engineer Technical Assignment — Complete End-to-End Solution

**Candidate:** Sarthak Shirbhate  
**Role:** Senior DevOps / SRE Engineer  
**Organization:** 8Byte.ai  
**Repository:** [https://github.com/sarthak24shirbhate/8byte-devops-assignment](https://github.com/sarthak24shirbhate/8byte-devops-assignment)  

---

## 1. Project Overview

This repository represents the complete, production-oriented Infrastructure-as-Code, Application Containerization, CI/CD Automation, Monitoring, and Logging implementation for the 8Byte.ai DevOps Engineer Technical Assignment.

The system provisions a highly available, multi-AZ Virtual Private Cloud (VPC) on AWS running a containerized Python FastAPI microservice on Amazon ECS Fargate behind an Application Load Balancer (ALB), backed by an Amazon RDS PostgreSQL database isolated in private database subnets. The application lifecycle is governed by automated GitHub Actions CI/CD pipelines with Trivy security scanning, AWS OpenID Connect (OIDC) authentication, automated staging smoke tests, and manual approval gates for production deployments.

---

## 2. End-to-End Architecture Diagram

```mermaid
graph TD
    subgraph GitHub_Ecosystem ["Development & CI/CD Pipeline (GitHub)"]
        Dev["Developer: Sarthak Shirbhate"] -->|Git Push / PR| Repo["GitHub Repository<br/>(8byte-devops-assignment)"]
        Repo -->|PR Created| PR_Workflow["GitHub Actions: PR Validation<br/>• Code Linting (Black & Flake8)<br/>• Unit & Integration Tests (Pytest)<br/>• Dependency Scan (Trivy)<br/>• Terraform Validate"]
        Repo -->|Merged to main| Main_Workflow["GitHub Actions: CD Pipeline"]
        
        Main_Workflow -->|1. Test & Build| Docker_Build["Docker Build & Trivy Image Scan"]
        Docker_Build -->|2. Keyless Auth (OIDC)| ECR["Amazon ECR Registry<br/>(8byte-app:sha-xyz)"]
        ECR -->|3. Deploy & Smoke Test| Staging_Deploy["Staging ECS Service<br/>(Automated Health Check)"]
        Staging_Deploy -->|4. Manual Gate| Approval_Gate{{"Production Approval Gate<br/>(GitHub Environment: production)"}}
        Approval_Gate -->|5. Deploy Approved Image| Prod_Deploy["Production ECS Service"]
    end

    subgraph AWS_Cloud ["AWS Cloud Infrastructure (us-east-1)"]
        subgraph VPC ["Amazon VPC (10.0.0.0/16) — Multi-AZ"]
            subgraph Public_Subnets ["Public Subnets (AZ-1 & AZ-2)"]
                IGW["Internet Gateway"]
                ALB["Application Load Balancer<br/>[SG: alb-sg | Inbound :80/:443]"]
                NAT["NAT Gateway (AZ-1 Egress)"]
            end

            subgraph Private_Subnets ["Private Subnets (AZ-1 & AZ-2)"]
                subgraph ECS_Cluster ["ECS Fargate Service"]
                    Task1["ECS Task 1 (FastAPI)"]
                    Task2["ECS Task 2 (FastAPI)"]
                end
                
                SM["AWS Secrets Manager<br/>(Master DB Credentials)"]

                subgraph DB_Subnets ["RDS DB Subnet Group"]
                    RDS[("Amazon RDS PostgreSQL 15.7<br/>[SG: rds-sg | Inbound :5432 strictly from ecs-sg]<br/>Encrypted gp3 Storage")]
                end
            end
        end

        subgraph Observability ["Observability & Monitoring Tier"]
            CW_Logs["CloudWatch Log Group<br/>(/ecs/8byte-dev-app)"]
            CW_Dash1["Dashboard 1: Infrastructure Health<br/>(CPU, Memory, Tasks, ALB 5xx, RDS IOPS)"]
            CW_Dash2["Dashboard 2: Application Health<br/>(Request Rate, Latency p95/p99, Status 2xx/4xx/5xx)"]
            CW_Alarms["CloudWatch Alarms<br/>(High CPU, Unhealthy Targets, 5xx Spikes)"]
            SNS["Amazon SNS Alert Topic"]
        end
    end

    ALB -->|Forward Traffic :8000| Task1
    ALB -->|Forward Traffic :8000| Task2
    Task1 -->|SQL Queries :5432| RDS
    Task2 -->|SQL Queries :5432| RDS
    Task1 -.->|Task Execution: Retrieve Secret| SM
    Task1 -.->|Ship Structured JSON Logs| CW_Logs
    Task1 -.->|Outbound Egress| NAT
    NAT -->|Egress to Internet| IGW
    CW_Alarms --> SNS
```

---

## 3. Architecture Decisions & Justifications

| Decision | Selection | Technical Rationale |
| :--- | :--- | :--- |
| **Compute Platform** | **ECS Fargate** | Eliminates server provisioning, OS patching, and host scaling overhead. Provides native task-level IAM isolation with lower idle cost than EKS control plane ($73/mo). |
| **Load Balancing** | **Application Load Balancer (ALB)** | Layer-7 traffic routing, path-based routing capabilities, direct integration with ECS `awsvpc` IP targets, and SSL/TLS termination. |
| **Network Isolation** | **Private Subnets for Compute & Data** | Zero public IP allocation on ECS containers and RDS. Prevents direct internet-based reconnaissance and brute-force attacks. |
| **Security Groups** | **Security-Group-to-Security-Group Chains** | Eliminates fragile hardcoded IP rules. ALB forwards to ECS SG, and RDS permits port 5432 **only** from ECS SG. |
| **CI/CD Authentication** | **AWS IAM OpenID Connect (OIDC)** | Eliminates static, long-lived AWS Access Keys in GitHub Secrets. Ephemeral short-lived STS tokens expire automatically. |
| **Secrets Management** | **AWS Secrets Manager** | Dynamic 24-character cryptographic password generation with in-memory injection into ECS containers via Task Execution Role. |
| **State Management** | **Remote S3 + DynamoDB Locking** | S3 bucket with AES-256 encryption, versioning, and public access blocks; DynamoDB table for distributed state locking to prevent concurrent pipeline races. |
| **Deployment Strategy** | **Staging + Manual Approval Gate** | Validates container images and executes automated smoke tests in Staging before a human reviewer approves promotion to Production. |

---

## 4. Repository Structure

```
8byte-infrastructure/
├── .github/
│   └── workflows/
│       ├── pr-validation.yml       # PR validation: linting, pytest, Trivy, terraform validate
│       └── deploy.yml              # Main CD: Docker build, scan, ECR push, Staging, Approval, Prod
├── app/
│   ├── config.py                   # Pydantic v2 application settings
│   ├── database.py                 # SQLAlchemy engine and connection manager
│   ├── models.py                   # Pydantic validation schemas & SQLAlchemy ORM models
│   ├── main.py                     # FastAPI app: structured logging, /health, /api/v1/metrics, items CRUD
│   ├── requirements.txt            # Production runtime dependencies
│   └── requirements-dev.txt        # Development and testing dependencies
├── tests/
│   ├── __init__.py
│   ├── conftest.py                 # Test fixtures & database setup
│   ├── test_app.py                 # Unit tests for endpoints, metrics, and latency headers
│   └── test_integration.py         # Integration tests for database CRUD workflows
├── terraform/
│   ├── versions.tf                 # Pinned Terraform >= 1.5.0, AWS ~> 5.40, Random ~> 3.5
│   ├── providers.tf                # AWS provider with global tags
│   ├── backend.tf                  # Remote state S3 backend configuration
│   ├── locals.tf                   # Shared local naming and resource tags
│   ├── variables.tf                # Input variable definitions with validation
│   ├── outputs.tf                  # Exported outputs for CI/CD and deployment
│   ├── main.tf                     # Root orchestration wiring all 8 modules
│   ├── terraform.tfvars.example    # Safe parameter example
│   ├── bootstrap/                  # Remote state S3 bucket & DynamoDB lock table provisioning
│   └── modules/
│       ├── vpc/                    # VPC, 2 public & 2 private subnets, IGW, NAT GW, Route Tables
│       ├── security-groups/        # Least-privilege ALB, ECS, and RDS security groups
│       ├── alb/                    # Public ALB, IP Target Group, HTTP/HTTPS listeners
│       ├── ecs/                    # ECS Fargate Cluster, Task Definition, Service, IAM Roles, CloudWatch
│       ├── rds/                    # RDS PostgreSQL 15.7, DB Subnet Group, Secrets Manager
│       ├── ecr/                    # Amazon ECR Repository with scan-on-push & lifecycle rules
│       ├── oidc/                   # GitHub Actions OIDC Provider & Least-Privilege Deployment IAM Role
│       └── monitoring/             # 2 CloudWatch Dashboards, 5 Metric Alarms & SNS Alert Topic
├── docs/
│   ├── Loom_Recording_Checklist.md # Step-by-step Loom recording checklist & presentation script
│   └── SUBMISSION.md               # Assignment requirement matrix & gap analysis
├── Dockerfile                      # Hardened multi-stage Dockerfile (non-root appuser:10001)
├── docker-compose.yml              # Local multi-container development stack (App + PostgreSQL)
├── .dockerignore                   # Optimizes build context
├── .gitignore                      # Prevents state files, credentials, and cache from Git
├── README.md                       # Complete assignment documentation
└── CHALLENGES.md                   # Real engineering challenges encountered and resolutions
```

---

## 5. Local Setup & Testing

### 5.1 Run Locally with Python Virtual Environment
```bash
# 1. Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# 2. Install dependencies
pip install -r app/requirements.txt -r app/requirements-dev.txt

# 3. Run Unit and Integration Tests
pytest tests/ -v --cov=app

# 4. Start the Application Locally
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 5.2 Run Locally via Docker & Docker Compose
```bash
# Build and run application and PostgreSQL database
docker-compose up --build -d

# Verify application health
curl -s http://localhost:8000/health | jq .

# Verify operational metrics
curl -s http://localhost:8000/api/v1/metrics | jq .

# Test database CRUD endpoint
curl -X POST http://localhost:8000/api/v1/items \
  -H "Content-Type: application/json" \
  -d '{"title": "Deploy infrastructure", "description": "Provisioned with Terraform"}'

# Tear down local stack
docker-compose down -v
```

---

## 6. Infrastructure Provisioning (Terraform)

### Step 6.1: Bootstrap Remote State Infrastructure
```bash
cd terraform/bootstrap/

# Initialize and create S3 bucket and DynamoDB locking table
terraform init
terraform apply -auto-approve
```
*Note the `s3_bucket_name` and `dynamodb_table_name` outputs.*

### Step 6.2: Deploy Core Infrastructure
```bash
cd ../  # (into terraform/)

# Configure backend.tf with values from bootstrap output
terraform init -migrate-state

# Review execution plan
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan
```

---

## 7. CI/CD Deployment Automation

### Workflow 1: Pull Request Validation (`pr-validation.yml`)
- **Triggers:** Every Pull Request opened or updated against `main`.
- **Jobs:**
  1. **Linting & Code Quality:** Runs `black --check` and `flake8`.
  2. **Unit & Integration Tests:** Executes `pytest tests/` with code coverage reports.
  3. **Dependency Vulnerability Scan:** Runs Trivy scanner to detect CVEs in third-party packages.
  4. **Terraform Validation:** Executes `terraform fmt -check` and `terraform validate`.

### Workflow 2: Build, Push & Multi-Stage Deployment (`deploy.yml`)
- **Triggers:** Every push or merge to the `main` branch.
- **Jobs:**
  1. **Test Suite:** Executes pytest test suite.
  2. **Docker Build & Trivy Scan:** Builds container image and runs container security scan.
  3. **AWS OIDC Authentication:** Obtains short-lived STS credentials via OpenID Connect (no stored AWS keys).
  4. **ECR Push:** Pushes versioned image (`8byte-app:sha-<hash>-build-<number>`).
  5. **Deploy to Staging:** Deploys image to Staging ECS service and executes automated smoke tests.
  6. **Manual Production Approval Gate:** Pauses workflow in GitHub Environment `production` awaiting designated reviewer approval.
  7. **Deploy to Production:** Rolls out the exact approved container image to the Production ECS service.
  8. **Notification:** Sends alert to Slack webhook on workflow failure.

---

## 8. Monitoring, Logging & Dashboards

### CloudWatch Dashboards Provisioned:
1. **`8byte-dev-infrastructure-health`**:
   - ECS Fargate CPU & Memory Utilization time-series graphs.
   - RDS PostgreSQL CPU Utilization & Active Database Connections.
   - ALB Request Volume & Target Response Latency.
   - Target Group Healthy vs. Unhealthy Task Counts.
2. **`8byte-dev-application-health`**:
   - HTTP Status Code Distribution (2XX Success, 4XX Client Error, 5XX Server Error).
   - Target Response Time Percentiles (`p95`, `p99`, `Average`).
   - RDS Free Storage Space & Disk Read/Write IOPS.

### CloudWatch Alarms Configured:
- `8byte-dev-ecs-high-cpu`: Triggers when ECS CPU >= 80% for 2 consecutive minutes.
- `8byte-dev-ecs-high-memory`: Triggers when ECS Memory >= 80% for 2 consecutive minutes.
- `8byte-dev-alb-unhealthy-hosts`: Triggers when any ECS task fails ALB health checks.
- `8byte-dev-alb-high-5xx`: Triggers when target 5XX error count exceeds 5 in 1 minute.
- `8byte-dev-rds-high-cpu`: Triggers when RDS PostgreSQL CPU utilization >= 80%.

---

## 9. Backup & Secrets Management Strategy

1. **Secrets Management:**
   - Database credentials are dynamically generated using `random_password` (24 characters, filtered for SQL safety).
   - Credential JSON is stored in AWS Secrets Manager (`aws_secretsmanager_secret`).
   - The ECS Task Definition references the secret ARN via `valueFrom`, allowing the ECS agent to inject the password directly into memory at container launch. Plaintext passwords never exist in source code, `.tfvars`, or Terraform outputs.
2. **Backup Strategy:**
   - **Automated RDS Snapshots:** Configured daily with a 7-day retention period (`backup_retention_period = 7`).
   - **Point-in-Time Recovery (PITR):** Transaction logs continuously archived allowing restoration to any second within the retention window.
   - **S3 State Versioning:** The Terraform state bucket enforces versioning to guard against state corruption.

---

## 10. Cost Optimization (Dev vs. Production)

| Architecture Component | Dev / Assignment Setup | Production Recommendation | Cost Rationalization |
| :--- | :--- | :--- | :--- |
| **NAT Gateway** | Single NAT Gateway (`single_nat_gateway = true`) | Multi-AZ (1 per AZ) | Saves ~$32/month per additional AZ while providing private ECS egress |
| **RDS Instance** | `db.t3.micro` Single-AZ | `db.r6g.xlarge` Multi-AZ with Read Replicas | Eliminates multi-AZ DB standby licensing/instance costs for testing |
| **ECS Compute** | Fargate (0.25 vCPU, 512 MiB) | Fargate with Target Tracking Auto Scaling | Minimal reservation while fully verifying container lifecycle |
| **CloudWatch Logs** | 7-day log retention | 90-day retention with S3 Glacier export | Prevents unbounded log storage charges |

---

## 11. Cleanup / Teardown Instructions

```bash
cd terraform/

# 1. Destroy all core infrastructure (VPC, ALB, ECS, RDS, Secrets Manager, Dashboards)
terraform destroy -auto-approve

# 2. Destroy remote state bootstrap infrastructure (if no longer needed)
cd bootstrap/
terraform destroy -auto-approve
```
