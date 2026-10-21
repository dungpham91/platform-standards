output "private_subnet_ids" {
  description = "Private subnet IDs for workloads."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs for load balancers."
  value       = module.vpc.public_subnets
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}
