output "data_security_group_id" {
  description = "Security group for RDS and Redis."
  value       = aws_security_group.data.id
}

output "db_endpoint" {
  description = "RDS endpoint for order service."
  value       = aws_db_instance.orders.address
  sensitive   = true
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint."
  value       = aws_elasticache_replication_group.cache.primary_endpoint_address
  sensitive   = true
}
