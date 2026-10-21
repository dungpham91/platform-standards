variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to reach Postgres/Redis (app tier)."
}

variable "db_password" {
  type        = string
  description = "RDS master password."
  sensitive   = true
}

variable "db_username" {
  type        = string
  description = "RDS master username."
  default     = "trading_admin"
}

variable "enable_multi_az" {
  type        = bool
  description = "RDS Multi-AZ."
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key for storage encryption."
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names and tags."
}

variable "postgres_engine_version" {
  type        = string
  description = "PostgreSQL engine version pin (set in env tfvars after AWS release review)."
}

variable "postgres_instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for data tier."
}

variable "redis_auth_token" {
  type        = string
  description = "Required when Redis transit encryption is enabled (min 16 chars)."
  sensitive   = true
  default     = null
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version pin from env tfvars."
}

variable "redis_node_type" {
  type        = string
  description = "ElastiCache node type."
}

variable "redis_num_cache_clusters" {
  type        = number
  description = "Redis cluster count (2+ for failover in prod)."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}
