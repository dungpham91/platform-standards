variable "alb_arn_suffix" {
  type        = string
  description = "ALB ARN suffix for CloudWatch ALB metrics."
  default     = ""
}

variable "enable_slack_notifications" {
  type        = bool
  description = "Subscribe SNS alerts to Slack via Lambda."
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

variable "kms_key_arn" {
  type        = string
  description = "CMK for SNS encryption."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names and tags."
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack incoming webhook for platform alerts (store in CI/AWS Secrets Manager in prod)."
  sensitive   = true
  default     = ""
}
