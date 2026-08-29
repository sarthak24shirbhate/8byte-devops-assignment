# Engineering Challenges & Resolutions — 8Byte.ai DevOps Engineer Assignment

**Candidate:** Sarthak Shirbhate  
**Role:** Senior DevOps / SRE Engineer  
**Date:** August 2026  
**Assignment:** 8Byte.ai DevOps Engineer Technical Assignment  

---

### Challenge 1: Circular Dependency in Security-Group-to-Security-Group Rule Definitions

- **Problem:** Creating strict least-privilege security group rules where the ALB allows outbound traffic only to ECS tasks, and ECS tasks allow inbound traffic only from the ALB, causes Terraform dependency graph deadlocks when defined as inline attributes.
- **Impact:** Terraform execution graph calculation fails with cyclic dependency errors during `terraform plan` / `terraform apply`.
- **Root Cause:** Defining inline `ingress` and `egress` blocks inside both `aws_security_group.alb` and `aws_security_group.ecs` creates a bidirectional resource dependency where resource A cannot be created without resource B's ID, and vice-versa.
- **Investigation:** Analyzed Terraform directed acyclic graph (DAG) node evaluation.
- **Resolution:** Decoupled security group definitions from their rules using standalone `aws_security_group_rule` resources. The security groups are created first with their identifiers, followed by the specific ingress/egress rules referencing the target security group IDs.
- **Validation:** Executed `terraform validate` and `terraform plan`. The execution graph constructed a clean acyclic directed graph.
- **Key Learning:** Always separate security groups from cross-referencing rules when implementing zero-trust perimeter network boundaries in Terraform.

---

### Challenge 2: Chicken-and-Egg Dilemma with Remote State Backend Creation

- **Problem:** Terraform S3 backend configuration requires the S3 bucket and DynamoDB table to already exist before `terraform init` can succeed. However, defining the state bucket in the same root module makes automated provisioning impossible from scratch.
- **Impact:** New environments cannot be initialized automatically using `terraform init` without manual AWS Console intervention or pre-existing state infrastructure.
- **Root Cause:** Terraform backend initialization occurs before any resources in the root module are evaluated or created.
- **Investigation:** Evaluated bootstrap patterns in enterprise IaC architectures.
- **Resolution:** Created an isolated, standalone bootstrap module in `terraform/bootstrap/`. The bootstrap module provisions the S3 bucket (with AES-256 encryption, versioning, and public access blocks) and the DynamoDB locking table independently. Documented the 2-step initialization workflow clearly in `README.md`.
- **Validation:** Successfully ran `terraform init -backend=false` and `terraform validate` inside `terraform/bootstrap/`, outputting the exact backend configuration snippet required for `backend.tf`.
- **Key Learning:** Infrastructure bootstrap dependencies must always be architecturally separated from application infrastructure to maintain reproducible GitOps workflows.

---

### Challenge 3: SQLAlchemy Schema Initialization during FastAPI TestClient Execution

- **Problem:** Running `pytest` on integration test endpoints resulted in `OperationalError: no such table: items`.
- **Impact:** Unit and integration test suite failed in CI/CD pre-merge validation.
- **Root Cause:** FastAPI's `lifespan` handler is not triggered by default when instantiating `TestClient(app)` outside of an explicit ASGI context manager, preventing `Base.metadata.create_all(bind=engine)` from executing prior to test endpoint requests.
- **Investigation:** Examined FastAPI and Starlette test client lifecycle execution flow.
- **Resolution:** Created a dedicated `tests/conftest.py` with an autouse session fixture `setup_test_db()` that creates all database tables before test execution and tears them down after, alongside a `client` fixture using `with TestClient(app) as c: yield c`.
- **Validation:** Re-ran `pytest tests/ -v`. All 6 unit and integration test cases passed with 100% pass rate.
- **Key Learning:** Test suites must manage test database lifecycles independently of application runtime lifecycles via standardized test fixtures.

---

### Challenge 4: AWS IAM OpenID Connect (OIDC) Scoping for Keyless GitHub Actions Authentication

- **Problem:** Hardcoding long-lived AWS Access Keys in GitHub Secrets poses serious security credential exposure risks if a repository or workflow is compromised.
- **Impact:** Long-lived keys violate enterprise zero-trust security compliance.
- **Root Cause:** Traditional CI/CD setups rely on static IAM user credentials instead of federated identity tokens.
- **Investigation:** Researched GitHub Actions OpenID Connect (OIDC) integration with AWS Security Token Service (STS).
- **Resolution:** Implemented `modules/oidc/` provisioning an `aws_iam_openid_connect_provider` for `https://token.actions.githubusercontent.com` and an IAM role with a strict trust policy condition matching `repo:sarthak24shirbhate/8byte-devops-assignment:*` and audience `sts.amazonaws.com`.
- **Validation:** Validated IAM trust policy JSON structure against AWS STS OIDC federation standards.
- **Key Learning:** Ephemeral short-lived STS tokens via OIDC completely eliminate the risk of leaked permanent cloud credentials in CI/CD systems.

---

### Challenge 5: Secure RDS Master Password Injection into ECS Tasks without Plaintext Leakage

- **Problem:** ECS application containers require database credentials to establish database connections at startup, but embedding credentials in code, environment variables, or `.tfvars` violates security policies.
- **Impact:** Plaintext credentials exposed in git repositories, Terraform state files, or CloudWatch logs create severe compliance vulnerabilities.
- **Root Cause:** Passing database passwords directly via standard environment variables exposes them in task definition JSON and Terraform outputs.
- **Investigation:** Evaluated AWS Systems Manager Parameter Store vs. AWS Secrets Manager with ECS native integration.
- **Resolution:**
  1. Utilized Terraform's `random_password` resource with strict character filtering (excluding `@`, `/`, `"`, `'`, `\`).
  2. Stored the credentials directly into AWS Secrets Manager (`aws_secretsmanager_secret_version`).
  3. Configured the ECS Task Definition to use the `secrets` array pointing to the Secrets Manager ARN (`valueFrom = "${db_secret_arn}:password::"`).
  4. Attached a scoped IAM policy to the ECS Task Execution Role granting `secretsmanager:GetSecretValue` on only that specific secret ARN.
- **Validation:** Verified task definition JSON structure and validated that `terraform outputs` masks the master password, exporting only the Secret ARN and DB connection endpoint.
- **Key Learning:** Leveraging AWS native IAM execution role resolution for Secrets Manager ensures secrets are fetched in-memory at container startup without touching persistent configuration artifacts.

---

### Challenge 6: CloudWatch Dashboard Metric Dimension Resolution Across Modular Outputs

- **Problem:** CloudWatch metrics for Application Load Balancers and Target Groups require specific dimension formats (`app/<alb-name>/<id>` and `targetgroup/<tg-name>/<id>`), whereas standard Terraform resources often output full ARNs.
- **Impact:** CloudWatch Dashboard widgets display empty graphs (`No data available`) even when traffic is actively flowing through the load balancer.
- **Root Cause:** CloudWatch `AWS/ApplicationELB` namespace dimensions strictly require ARN Suffix strings rather than full ARNs.
- **Investigation:** Examined AWS CloudWatch ELB metrics documentation and Terraform `aws_lb` attributes.
- **Resolution:** Updated `modules/alb/outputs.tf` to export `aws_lb.main.arn_suffix` and `aws_lb_target_group.app.arn_suffix`, which were then wired directly into `modules/monitoring/main.tf` dashboard widget and alarm dimensions.
- **Validation:** Verified that dashboard JSON structures match the AWS CloudWatch metric dimension schema.
- **Key Learning:** Always inspect provider-specific metric dimension requirements when constructing IaC monitoring dashboards.

---

### Challenge 7: PyPI Package Resolution Failure for Trivy in CI Dependency Installation

- **Problem:** Initial GitHub Actions workflow execution failed during `Install Dependencies` step with `ERROR: No matching distribution found for trivy`.
- **Impact:** The CI/CD pipeline failed to execute unit/integration tests and halted before building Docker images.
- **Root Cause:** Trivy is a standalone Go binary executed via the dedicated GitHub Action `aquasecurity/trivy-action`, not a Python pip package on PyPI. Listing `trivy` in `requirements-dev.txt` caused `pip install` to fail.
- **Investigation:** Inspected failed GitHub Actions runner logs (`gh run view 33238249214 --log-failed`).
- **Resolution:** Replaced `trivy` with `pip-audit` in `requirements-dev.txt`, formatted all Python files with `black`, resolved unused variables in `app/main.py` and `app/database.py`, and added fallback checks for OIDC deployment.
- **Validation:** Re-ran GitHub Actions workflow (`run 33238554775`); all jobs (`Run Test Suite`, `Docker Build & Trivy Scan`, `Deploy Staging`, `Deploy Production`) completed with 100% green success status.
- **Key Learning:** Clearly delineate system-level binary tools (managed via GitHub Actions) from language-specific dependencies (managed via package managers).
