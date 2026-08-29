# Engineering Challenges & Resolutions

**Author:** Sarthak Shirbhate (DevOps / SRE Engineer)  
**Assignment:** 8Byte.ai Technical Assignment  

During the development and testing of this end-to-end assignment, I documented the real technical issues I ran into along with the root causes, fixes, and takeaways.

---

### 1. Cyclic Dependency between ALB and ECS Security Groups

- **Problem:** When I first defined the security groups for the ALB and ECS tasks, Terraform failed during `terraform plan` with a circular dependency error.
- **Root Cause:** I initially defined inline `ingress` and `egress` blocks inside both `aws_security_group.alb` and `aws_security_group.ecs`. Because the ALB egress pointed to the ECS security group ID and the ECS ingress pointed to the ALB security group ID, Terraform couldn't determine which security group to create first in its dependency graph (DAG).
- **Resolution:** I refactored the security groups to be created first with zero inline rules, and then attached standalone `aws_security_group_rule` resources. This allowed Terraform to create both security groups and then attach the cross-referencing rules cleanly.
- **Takeaway:** Always decouple cross-referencing security group rules into dedicated `aws_security_group_rule` resources when building zero-trust perimeter boundaries in Terraform.

---

### 2. S3 Remote State Backend Chicken-and-Egg Problem

- **Problem:** Terraform's remote backend configuration requires the target S3 bucket and DynamoDB table to already exist before `terraform init` can succeed. Putting the S3 bucket in the same root module caused `terraform init` to fail on a fresh account.
- **Root Cause:** Terraform initializes the backend before evaluating or provisioning any resources in the root module.
- **Resolution:** I isolated the state infrastructure into a standalone `terraform/bootstrap/` module. The workflow is simple: run `terraform apply` inside `bootstrap/` once, copy the output bucket name into `backend.tf`, and then run `terraform init -migrate-state` in the root directory.
- **Takeaway:** Always separate state storage lifecycle management from workload infrastructure in IaC repositories.

---

### 3. FastAPI TestClient Lifespan & SQLite Schema Initialization in Tests

- **Problem:** When I ran `pytest tests/`, the integration tests failed with `sqlite3.OperationalError: no such table: items`.
- **Root Cause:** FastAPI's `lifespan` context manager only executes when the ASGI app starts up normally or when `TestClient` is used as a context manager (`with TestClient(app) as client:`). Direct calls to `client.post()` skipped the lifespan hook where `Base.metadata.create_all()` was located.
- **Resolution:** I created a `tests/conftest.py` file with an autouse session fixture `setup_test_db()` to explicitly create and teardown the SQLite database schema for tests, and provided a standard `client` fixture using the context manager pattern.
- **Takeaway:** Test suites should manage database schemas and test fixtures independently of runtime application lifecycles.

---

### 4. Trivy Package Name Issue in Python Requirements

- **Problem:** The first GitHub Actions run failed on `pip install -r app/requirements-dev.txt` with `ERROR: No matching distribution found for trivy`.
- **Root Cause:** Trivy is a standalone binary tool written in Go that is executed in CI via GitHub Actions (`aquasecurity/trivy-action`), not a Python package on PyPI.
- **Resolution:** I removed `trivy` from `requirements-dev.txt` and added `pip-audit` for local Python dependency vulnerability scanning, while keeping container image security scanning handled by the Trivy GitHub Action in the workflow.
- **Takeaway:** Clearly separate OS/binary tools managed in CI runners from language-specific runtime dependencies.

---

### 5. Securely Injecting RDS Passwords into ECS Fargate Tasks

- **Problem:** The containerized application needs the PostgreSQL master password to connect to the database, but embedding credentials in code, `.tfvars`, or plain environment variables creates a security risk.
- **Root Cause:** Environment variables in task definitions are visible in the AWS Console and Terraform state outputs.
- **Resolution:** I used Terraform's `random_password` module to generate a 24-character cryptographic password with SQL-safe characters, stored the credential payload into AWS Secrets Manager, and configured the ECS task definition `secrets` block with `valueFrom = "${secret_arn}:password::"`. The ECS Task Execution Role was given scoped `secretsmanager:GetSecretValue` permissions to pull the secret directly into memory at container launch.
- **Takeaway:** Using AWS Secrets Manager with native ECS Task Execution Role injection guarantees secrets never touch source code, Git history, or container image layers.

---

### 6. CloudWatch ELB Metric Dimension Mismatch

- **Problem:** CloudWatch Dashboard widgets for the Application Load Balancer were showing empty graphs ("No data available").
- **Root Cause:** The `AWS/ApplicationELB` CloudWatch namespace requires dimension values in the `app/<name>/<id>` and `targetgroup/<name>/<id>` format (`arn_suffix`), whereas I was originally passing the full resource ARN.
- **Resolution:** I updated `modules/alb/outputs.tf` to export `aws_lb.main.arn_suffix` and `aws_lb_target_group.app.arn_suffix`, and wired those suffixes into `modules/monitoring/main.tf`.
- **Takeaway:** Always verify the exact dimension format expected by AWS CloudWatch namespaces when writing Terraform dashboard definitions.
