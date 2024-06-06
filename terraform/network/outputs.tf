output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The public subnets"
  value       = module.vpc.public_subnets
}

output "security_group_id" {
  description = "The default security group ID"
  value       = module.vpc.default_security_group_id
}

output "database_subnet_group" {
  description = "The database subnet group"
  value       = module.vpc.database_subnet_group
}

output "subnet_ids" {
  value = module.vpc.database_subnets
}