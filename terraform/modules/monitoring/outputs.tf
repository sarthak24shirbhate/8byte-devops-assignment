output "sns_alerts_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "infrastructure_dashboard_name" {
  description = "The name of the Infrastructure Health CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.infrastructure_health.dashboard_name
}

output "application_dashboard_name" {
  description = "The name of the Application Health CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.application_health.dashboard_name
}

output "alarm_arns" {
  description = "List of CloudWatch Metric Alarm ARNs"
  value = [
    aws_cloudwatch_metric_alarm.ecs_high_cpu.arn,
    aws_cloudwatch_metric_alarm.ecs_high_memory.arn,
    aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.arn,
    aws_cloudwatch_metric_alarm.alb_5xx.arn,
    aws_cloudwatch_metric_alarm.rds_high_cpu.arn
  ]
}
