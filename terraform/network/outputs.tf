output "database_subnet_group" {
  value = aws_db_subnet_group.database.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "private_subnet" {
  value = aws_subnet.private
}

output "public_subnet" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}