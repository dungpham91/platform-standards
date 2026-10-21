data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-${var.environment}-alb-sg"
  description = "Public HTTPS ingress to ALB."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Forward traffic to targets inside VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_lb" "public" {
  name                       = "${var.name_prefix}-${var.environment}-alb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = var.environment == "prod"

  tags = {
    Environment = var.environment
    Service     = "trading-edge"
    ManagedBy   = "terraform"
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.environment == "prod" ? 1 : 0
  resource_arn = aws_lb.public.arn
  web_acl_arn  = aws_wafv2_web_acl.edge[0].arn
}

resource "aws_wafv2_web_acl" "edge" {
  count       = var.environment == "prod" ? 1 : 0
  name        = "${var.name_prefix}-${var.environment}-waf"
  description = "Rate limit and AWS managed rules for trading API."
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "commonRules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment
  }
}
