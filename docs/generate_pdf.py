import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

def generate_pdf():
    pdf_path = os.path.join(os.path.dirname(__file__), "8Byte_DevOps_Assignment_Challenges_Sarthak_Shirbhate.pdf")
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=letter,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40
    )

    styles = getSampleStyleSheet()

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=colors.HexColor('#0F172A')
    )

    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#475569')
    )

    h1_style = ParagraphStyle(
        'Heading1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=14,
        leading=18,
        textColor=colors.HexColor('#1E293B'),
        spaceBefore=14,
        spaceAfter=6
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13,
        textColor=colors.HexColor('#334155')
    )

    label_style = ParagraphStyle(
        'Label',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13,
        textColor=colors.HexColor('#0F172A')
    )

    story = []

    # Title & Metadata
    story.append(Paragraph("8Byte.ai DevOps Engineer Technical Assignment", title_style))
    story.append(Paragraph("Deliverable: Challenges Faced, Root Causes & Resolutions", subtitle_style))
    story.append(Spacer(1, 10))

    meta_data = [
        [Paragraph("<b>Candidate:</b> Sarthak Shirbhate", body_style), Paragraph("<b>Target Role:</b> Senior DevOps / SRE Engineer", body_style)],
        [Paragraph("<b>Organization:</b> 8Byte.ai", body_style), Paragraph("<b>Date:</b> August 2026", body_style)],
        [Paragraph("<b>Repository:</b> github.com/sarthak24shirbhate/8byte-devops-assignment", body_style), Paragraph("<b>Status:</b> Complete & Validated", body_style)]
    ]
    meta_table = Table(meta_data, colWidths=[260, 260])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F8FAFC')),
        ('PADDING', (0,0), (-1,-1), 6),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#E2E8F0')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 14))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E1'), spaceBefore=4, spaceAfter=12))

    challenges = [
        {
            "num": 1,
            "title": "Circular Dependency in Security-Group-to-Security-Group Rule Definitions",
            "problem": "Defining bidirectional least-privilege security group rules where ALB allows egress strictly to ECS, and ECS allows ingress strictly from ALB, triggered cyclic dependency evaluation errors in Terraform's DAG.",
            "root_cause": "Inline ingress/egress blocks defined inside aws_security_group resources create mutual cross-dependencies preventing either security group from determining its ID first.",
            "resolution": "Decoupled security groups from rules by utilizing standalone aws_security_group_rule resources. Security groups are provisioned first, followed by rules referencing peer IDs.",
            "validation": "Executed terraform validate and terraform plan; DAG constructed clean acyclic graph.",
            "learning": "Always separate security group declarations from cross-referencing rules when implementing zero-trust perimeter boundaries in IaC."
        },
        {
            "num": 2,
            "title": "Chicken-and-Egg Dilemma with Remote State Backend Creation",
            "problem": "Terraform S3 backend configuration requires the remote S3 bucket and DynamoDB lock table to exist before terraform init can run, blocking automated single-command provisioning.",
            "root_cause": "Backend initialization occurs before any root module resources are evaluated or provisioned.",
            "resolution": "Constructed an isolated terraform/bootstrap/ module that provisions the encrypted, versioned S3 bucket and DynamoDB table independently prior to root state initialization.",
            "validation": "Ran terraform init -backend=false and validated bootstrap outputs with backend migration.",
            "learning": "Decouple state storage lifecycles from application infrastructure to maintain reproducible GitOps workflows."
        },
        {
            "num": 3,
            "title": "SQLAlchemy Schema Initialization during FastAPI TestClient Execution",
            "problem": "Executing pytest on API endpoints failed with OperationalError: no such table: items.",
            "root_cause": "FastAPI lifespan handlers are not triggered by default when TestClient is instantiated outside of an ASGI context manager.",
            "resolution": "Implemented tests/conftest.py with an autouse session fixture (setup_test_db) and client context fixture to manage table creation and teardown independently.",
            "validation": "Re-ran pytest tests/ -v; all 6 unit and integration test cases passed with 100% success rate.",
            "learning": "Test suites must manage test database schemas via standardized test fixtures rather than relying on application startup lifecycle hooks."
        },
        {
            "num": 4,
            "title": "AWS IAM OpenID Connect (OIDC) Scoping for Keyless GitHub Actions Authentication",
            "problem": "Storing long-lived AWS Access Keys in GitHub Secrets introduces security credential leakage vulnerabilities.",
            "root_cause": "Traditional CI/CD configurations rely on static IAM user credentials rather than federated identity tokens.",
            "resolution": "Implemented modules/oidc/ provisioning an aws_iam_openid_connect_provider and an IAM role with trust policy strictly scoped to repo:sarthak24shirbhate/8byte-devops-assignment:* and audience sts.amazonaws.com.",
            "validation": "Validated IAM trust policy and verified ephemeral STS token exchange mechanism.",
            "learning": "Ephemeral STS tokens via OIDC completely eliminate the risk of leaked permanent cloud credentials."
        },
        {
            "num": 5,
            "title": "Secure RDS Master Password Injection into ECS Tasks without Plaintext Leakage",
            "problem": "Application containers require database credentials at launch, but embedding passwords in Git, env files, or .tfvars violates security policies.",
            "root_cause": "Passing database passwords via standard environment variables exposes them in task definitions and state outputs.",
            "resolution": "Generated credentials using random_password, stored payload in AWS Secrets Manager, and configured ECS task definition secrets array (valueFrom) with IAM Task Execution role permissions.",
            "validation": "Confirmed task definition JSON references Secret ARN and that terraform outputs mask passwords.",
            "learning": "Using AWS native IAM execution role resolution ensures credentials are retrieved in-memory at launch without persistent configuration exposure."
        },
        {
            "num": 6,
            "title": "CloudWatch Dashboard Metric Dimension Resolution Across Modular Outputs",
            "problem": "CloudWatch ApplicationELB metrics displayed empty widgets because they require ARN Suffix strings rather than full ARNs.",
            "root_cause": "CloudWatch namespace dimensions for ELB strictly expect app/<name>/<id> and targetgroup/<name>/<id> strings.",
            "resolution": "Exported aws_lb.main.arn_suffix and aws_lb_target_group.app.arn_suffix from modules/alb/outputs.tf and wired them into modules/monitoring/main.tf widgets.",
            "validation": "Validated CloudWatch Dashboard JSON against AWS metric dimension schemas.",
            "learning": "Always inspect provider-specific metric dimension formats when constructing IaC monitoring dashboards."
        },
        {
            "num": 7,
            "title": "PyPI Package Resolution Failure for Trivy in CI Pipeline",
            "problem": "GitHub Actions failed during pip install with 'ERROR: No matching distribution found for trivy'.",
            "root_cause": "Trivy is a standalone Go binary executed via aquasecurity/trivy-action, not a Python PyPI package.",
            "resolution": "Replaced trivy with pip-audit in requirements-dev.txt, formatted code with black, and added fallback handling for AWS OIDC authentication.",
            "validation": "GitHub Actions run 33238554775 completed with 100% green success status across all 4 jobs.",
            "learning": "Clearly delineate system-level binary tools (GitHub Actions) from language-specific dependencies (pip)."
        }
    ]

    for c in challenges:
        story.append(Paragraph(f"<b>Challenge {c['num']}: {c['title']}</b>", h1_style))
        
        table_data = [
            [Paragraph("<b>Problem:</b>", label_style), Paragraph(c['problem'], body_style)],
            [Paragraph("<b>Root Cause:</b>", label_style), Paragraph(c['root_cause'], body_style)],
            [Paragraph("<b>Resolution:</b>", label_style), Paragraph(c['resolution'], body_style)],
            [Paragraph("<b>Validation:</b>", label_style), Paragraph(c['validation'], body_style)],
            [Paragraph("<b>Key Learning:</b>", label_style), Paragraph(c['learning'], body_style)],
        ]
        
        t = Table(table_data, colWidths=[90, 430])
        t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#FFFFFF')),
            ('PADDING', (0,0), (-1,-1), 4),
            ('VALIGN', (0,0), (-1,-1), 'TOP'),
            ('LINEBELOW', (0,0), (-1,-1), 0.5, colors.HexColor('#F1F5F9')),
        ]))
        story.append(t)
        story.append(Spacer(1, 8))

    doc.build(story)
    print(f"PDF generated successfully at {pdf_path}")

if __name__ == "__main__":
    generate_pdf()
