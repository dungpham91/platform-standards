output "alb_arn" {
  description = "Public ALB ARN."
  value       = aws_lb.public.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics."
  value       = aws_lb.public.arn_suffix
}

output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = aws_lb.public.dns_name
}
