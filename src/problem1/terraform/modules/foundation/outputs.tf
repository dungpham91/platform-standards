output "audit_bucket_id" {
  description = "Central audit log bucket."
  value       = aws_s3_bucket.audit.id
}

output "kms_key_arn" {
  description = "Platform KMS key ARN for encryption at rest."
  value       = aws_kms_key.platform.arn
}
