resource "aws_kms_key" "platform" {
  description             = "${var.name_prefix} ${var.environment} platform encryption"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-platform-kms"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "platform" {
  name          = "alias/${var.name_prefix}-${var.environment}-platform"
  target_key_id = aws_kms_key.platform.key_id
}

resource "aws_s3_bucket" "audit" {
  bucket = var.audit_bucket_name

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-audit"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket = aws_s3_bucket.audit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.platform.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "audit" {
  bucket = aws_s3_bucket.audit.id

  target_bucket = aws_s3_bucket.audit.id
  target_prefix = "s3-access-logs/"
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.name_prefix}-${var.environment}"
  kms_key_id        = aws_kms_key.platform.arn
  retention_in_days = 90

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "${var.name_prefix}-${var.environment}-cloudtrail-cw"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch-logs"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "platform" {
  name                          = "${var.name_prefix}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.audit.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.platform.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch.arn

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_guardduty_detector" "this" {
  enable = true

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
