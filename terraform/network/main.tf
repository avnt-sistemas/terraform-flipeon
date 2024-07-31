data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
    ProjectGroup = var.project_group
  }
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

# Criação do NAT Gateway
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "${var.project_name}-nat-gateway"
    ProjectGroup = var.project_group
  }
}

# Criação do Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-internet-gateway"
    ProjectGroup = var.project_group
  }
}

# Criação da Tabela de Roteamento para as Sub-redes Públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.project_name}-public-route-table"
    ProjectGroup = var.project_group
  }
}

# Associação das Sub-redes Públicas à Tabela de Roteamento Pública
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Criação da Tabela de Roteamento para as Sub-redes Privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
  tags = {
    Name = "${var.project_name}-private-route-table"
    ProjectGroup = var.project_group
  }
}

# Associação das Sub-redes Privadas à Tabela de Roteamento Privada
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Criação do grupo de sub-redes do RDS
resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.public[*].id  # Sub-redes privadas devem estar em múltiplas AZs

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
    ProjectGroup = var.project_group
  }
}
