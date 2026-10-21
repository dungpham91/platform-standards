output "sns_topic_arn" {
  description = "Platform alerts SNS topic."
  value       = aws_sns_topic.platform_alerts.arn
}
