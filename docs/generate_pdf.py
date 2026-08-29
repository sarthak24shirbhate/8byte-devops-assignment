import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
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
        fontSize=18,
        leading=22,
        textColor=colors.HexColor('#0F172A')
    )

    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor('#475569')
    )

    h1_style = ParagraphStyle(
        'Heading1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#1E293B'),
        spaceBefore=10,
        spaceAfter=4
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=12.5,
        textColor=colors.HexColor('#334155')
    )

    label_style = ParagraphStyle(
        'Label',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=12.5,
        textColor=colors.HexColor('#0F172A')
    )

    story = []

    # Title & Metadata
    story.append(Paragraph("8Byte.ai DevOps / SRE Assignment: Challenges & Resolutions", title_style))
    story.append(Paragraph("Author: Sarthak Shirbhate (DevOps / SRE Engineer)", subtitle_style))
    story.append(Spacer(1, 8))

    meta_data = [
        [Paragraph("<b>Candidate:</b> Sarthak Shirbhate", body_style), Paragraph("<b>Target Role:</b> Senior DevOps / SRE Engineer", body_style)],
        [Paragraph("<b>Target Cloud:</b> AWS (us-east-1)", body_style), Paragraph("<b>Repository:</b> github.com/sarthak24shirbhate/8byte-devops-assignment", body_style)]
    ]
    meta_table = Table(meta_data, colWidths=[260, 260])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F8FAFC')),
        ('PADDING', (0,0), (-1,-1), 5),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#E2E8F0')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 10))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E1'), spaceBefore=2, spaceAfter=8))

    challenges = [
        {
            "num": 1,
            "title": "Cyclic Dependency between ALB and ECS Security Groups",
            "problem": "Defining bidirectional least-privilege security group rules where ALB allows egress to ECS, and ECS allows ingress from ALB, caused cyclic dependency errors in Terraform's DAG.",
            "root_cause": "Inline ingress/egress blocks defined inside aws_security_group resources created mutual cross-dependencies preventing either group from determining its ID first.",
            "resolution": "Decoupled security groups from rules using standalone aws_security_group_rule resources so groups are created first, followed by cross-referencing rules.",
            "takeaway": "Always separate security group declarations from cross-referencing rules when implementing zero-trust perimeter boundaries in IaC."
        },
        {
            "num": 2,
            "title": "S3 Remote State Backend Chicken-and-Egg Problem",
            "problem": "Terraform S3 backend configuration requires the remote S3 bucket and DynamoDB lock table to exist before terraform init can run, blocking automated single-command provisioning.",
            "root_cause": "Backend initialization occurs before any root module resources are evaluated or provisioned.",
            "resolution": "Created an isolated terraform/bootstrap/ module that provisions the encrypted, versioned S3 bucket and DynamoDB table independently prior to root state initialization.",
            "takeaway": "Decouple state storage lifecycles from application infrastructure to maintain clean GitOps workflows."
        },
        {
            "num": 3,
            "title": "FastAPI TestClient Lifespan & SQLite Schema Initialization in Tests",
            "problem": "Running pytest on API integration endpoints failed with OperationalError: no such table: items.",
            "root_cause": "FastAPI lifespan handlers are not triggered by default when TestClient is instantiated outside of an ASGI context manager.",
            "resolution": "Implemented tests/conftest.py with an autouse session fixture (setup_test_db) and client context fixture to manage table creation and teardown independently.",
            "takeaway": "Test suites must manage test database schemas via standardized test fixtures rather than relying on application startup lifecycle hooks."
        },
        {
            "num": 4,
            "title": "Trivy Package Name Issue in Python Requirements",
            "problem": "GitHub Actions failed during pip install with 'ERROR: No matching distribution found for trivy'.",
            "root_cause": "Trivy is a standalone Go binary executed via aquasecurity/trivy-action, not a Python PyPI package.",
            "resolution": "Replaced trivy with pip-audit in requirements-dev.txt for dependency scanning and kept container image scanning handled by the Trivy GitHub Action in CI.",
            "takeaway": "Clearly delineate system-level binary tools (GitHub Actions) from language-specific dependencies (pip)."
        },
        {
            "num": 5,
            "title": "Securely Injecting RDS Passwords into ECS Fargate Tasks",
            "problem": "Containers need database credentials at launch, but embedding passwords in Git, env files, or .tfvars violates security policies.",
            "root_cause": "Passing database passwords via standard environment variables exposes them in task definitions and state outputs.",
            "resolution": "Generated credentials using random_password, stored payload in AWS Secrets Manager, and configured ECS task definition secrets array (valueFrom) with IAM Task Execution role permissions.",
            "takeaway": "Using AWS native IAM execution role resolution ensures credentials are retrieved in-memory at launch without persistent configuration exposure."
        },
        {
            "num": 6,
            "title": "CloudWatch ELB Metric Dimension Mismatch",
            "problem": "CloudWatch ApplicationELB metrics displayed empty widgets because they require ARN Suffix strings rather than full ARNs.",
            "root_cause": "CloudWatch namespace dimensions for ELB strictly expect app/<name>/<id> and targetgroup/<name>/<id> strings.",
            "resolution": "Exported aws_lb.main.arn_suffix and aws_lb_target_group.app.arn_suffix from modules/alb/outputs.tf and wired them into modules/monitoring/main.tf widgets.",
            "takeaway": "Always inspect provider-specific metric dimension formats when constructing IaC monitoring dashboards."
        }
    ]

    for c in challenges:
        story.append(Paragraph(f"<b>{c['num']}. {c['title']}</b>", h1_style))
        
        table_data = [
            [Paragraph("<b>Problem:</b>", label_style), Paragraph(c['problem'], body_style)],
            [Paragraph("<b>Root Cause:</b>", label_style), Paragraph(c['root_cause'], body_style)],
            [Paragraph("<b>Resolution:</b>", label_style), Paragraph(c['resolution'], body_style)],
            [Paragraph("<b>Takeaway:</b>", label_style), Paragraph(c['takeaway'], body_style)],
        ]
        
        t = Table(table_data, colWidths=[80, 440])
        t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#FFFFFF')),
            ('PADDING', (0,0), (-1,-1), 3.5),
            ('VALIGN', (0,0), (-1,-1), 'TOP'),
            ('LINEBELOW', (0,0), (-1,-1), 0.5, colors.HexColor('#F1F5F9')),
        ]))
        story.append(t)
        story.append(Spacer(1, 5))

    doc.build(story)
    print(f"PDF generated successfully at {pdf_path}")

if __name__ == "__main__":
    generate_pdf()
