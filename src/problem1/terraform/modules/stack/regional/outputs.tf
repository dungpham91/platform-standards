output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = module.edge.alb_dns_name
}

output "audit_bucket_id" {
  description = "Audit log bucket."
  value       = module.foundation.audit_bucket_id
}

output "sns_topic_arn" {
  description = "Platform alerts SNS topic."
  value       = module.observability.sns_topic_arn
}

output "vpc_id" {
  description = "Regional VPC ID."
  value       = module.network.vpc_id
}
