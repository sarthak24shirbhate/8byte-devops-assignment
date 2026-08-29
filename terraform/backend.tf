# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM REMOTE STATE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
# To enable remote state storage in AWS S3 with state locking via DynamoDB:
# 1. Provision the state storage first by running `terraform apply` inside the `terraform/bootstrap/` directory.
# 2. Update the `bucket` and `dynamodb_table` values below with the outputs from the bootstrap step.
# 3. Run `terraform init -migrate-state` in this root directory.
#
# If running locally without remote S3 state (for initial dry-run validation), keep this block commented out.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # backend "s3" {
  #   bucket         = "8byte-dev-tfstate-<ACCOUNT_ID>-us-east-1"
  #   key            = "state/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "8byte-dev-tflocks"
  #   encrypt        = true
  # }
}
