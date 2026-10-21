output "app_security_group_id" {
  description = "Application tier SG — pass to data module allowed_security_group_ids."
  value       = aws_security_group.app.id
}
