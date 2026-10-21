data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "data" {
  name        = "${var.name_prefix}-${var.environment}-data-sg"
  description = "Postgres and Redis from application tier only."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "PostgreSQL from app tier"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "Redis from app tier"
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-data-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-${var.environment}-db"
  subnet_ids = var.private_subnet_ids

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_instance" "orders" {
  identifier     = "${var.name_prefix}-${var.environment}-orders"
  engine         = "postgres"
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class

  allocated_storage     = 50
  max_allocated_storage = 500
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.data.id]

  username = var.db_username
  password = var.db_password

  backup_retention_period          = var.environment == "prod" ? 35 : 7
  multi_az                         = var.enable_multi_az
  publicly_accessible              = false
  deletion_protection                 = true
  auto_minor_version_upgrade            = var.environment != "prod"
  iam_database_authentication_enabled   = true
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn

  tags = {
    Environment = var.environment
    Service     = "trading-orders-db"
    ManagedBy   = "terraform"
  }

  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-${var.environment}-redis"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "cache" {
  replication_group_id = "${var.name_prefix}-${var.environment}-redis"
  description          = "Order book and session cache"
  engine               = "redis"
  engine_version       = var.redis_engine_version
  node_type            = var.redis_node_type
  num_cache_clusters   = var.redis_num_cache_clusters

  auth_token                 = var.redis_auth_token
  automatic_failover_enabled = var.redis_num_cache_clusters > 1
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.data.id]

  tags = {
    Environment = var.environment
    Service     = "trading-cache"
    ManagedBy   = "terraform"
  }
}
