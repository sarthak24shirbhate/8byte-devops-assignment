output "s3_bucket_name" {
  description = "The name of the S3 bucket created for Terraform remote state"
  value       = aws_s3_bucket.tf_state.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket created for Terraform remote state"
  value       = aws_s3_bucket.tf_state.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.tf_locks.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.tf_locks.arn
}

output "backend_config_snippet" {
  description = "Example backend configuration snippet for backend.tf"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.tf_state.id}"
        key            = "state/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.tf_locks.name}"
        encrypt        = true
      }
    }
  EOT
}
