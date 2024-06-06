output "db_endpoint" {
  description = "db writer endpoint"
  value       = module.db.db_instance_endpoint
}

output "db_password" {
  description = "The generated password of the RDS instance"
  value       = module.db.db_instance_password
}

output "db_port" {
  description = "The port of the RDS instance"
  value       = module.db.db_instance_port
}
