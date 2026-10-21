# trivy:ignore:AVD-AWS-0104 -- Fargate tasks require HTTPS/DNS egress to AWS APIs; data paths use SG rules in stack/regional/sg_rules.tf
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-${var.environment}-app-sg"
  description = "ECS tasks / API tier — egress to data tier and HTTPS only."
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS to AWS APIs and external dependencies"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-app-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
