output "db_endpoint" {
  description = "DB writer endpoint"
  value       = aws_db_instance.db_writer.endpoint
}

output "db_password" {
  description = "The generated password of the RDS instance"
  value       = random_password.db_password.result  # O password gerado localmente
}

output "db_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.db_writer.port
}

output "db_instance_id" {
  description = "The ID of the DB instance"
  value = aws_db_instance.db_writer.id
}
