data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Outras configurações
}

# Criação das sub-redes privadas usando as variáveis
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "private-subnet-${count.index}"
    ProjectGroup = var.project_group
  }
}

# Criação das sub-redes públicas usando as variáveis
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "public-subnet-${count.index}"
    ProjectGroup = var.project_group
  }
}

# Criação do grupo de sub-redes do RDS
resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id  # Sub-redes privadas devem estar em múltiplas AZs

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
    ProjectGroup = var.project_group
  }
}