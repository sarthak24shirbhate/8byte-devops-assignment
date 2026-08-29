output "db_instance_id" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.postgres.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.postgres.arn
}

output "db_instance_address" {
  description = "The address / hostname of the RDS instance"
  value       = aws_db_instance.postgres.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint in address:port format"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_port" {
  description = "The database connection port"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_username" {
  description = "The database master username"
  value       = aws_db_instance.postgres.username
}

output "db_secretsmanager_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secretsmanager_secret_name" {
  description = "The name of the Secrets Manager secret storing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}
