output "github_actions_role_arn" {
  description = "The ARN of the IAM role assumed by GitHub Actions via OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "The name of the IAM role assumed by GitHub Actions via OIDC"
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
