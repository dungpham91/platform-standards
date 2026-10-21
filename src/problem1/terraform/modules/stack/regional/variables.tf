variable "audit_bucket_name" {
  type        = string
  description = "Globally unique audit bucket name."
}

variable "aws_region" {
  type        = string
  description = "AWS region for this stack."
}

variable "cost_center" {
  type        = string
  description = "Cost allocation tag (required by FinOps)."
}

variable "db_password" {
  type        = string
  description = "RDS master password."
  sensitive   = true
}

variable "enable_multi_az" {
  type        = bool
  description = "RDS Multi-AZ."
}

variable "enable_slack_notifications" {
  type        = bool
  description = "Send CloudWatch alarms to Slack."
  default     = false
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names and tags."
}

variable "owner" {
  type        = string
  description = "Technical owner tag."
}

variable "postgres_engine_version" {
  type        = string
  description = "PostgreSQL engine version pin."
}

variable "postgres_instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "redis_auth_token" {
  type        = string
  description = "Redis AUTH token when transit encryption is enabled."
  sensitive   = true
  default     = null
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version pin."
}

variable "redis_node_type" {
  type        = string
  description = "ElastiCache node type."
}

variable "redis_num_cache_clusters" {
  type        = number
  description = "Redis cluster count."
}

variable "service_name" {
  type        = string
  description = "Service tag for all resources."
  default     = "platform-trading"
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook for alarms."
  sensitive   = true
  default     = ""
}
