resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id


  tags = {
    Name         = "gw-${var.project_name}"
    ProjectGroup = var.project_group
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets.*.id)
  subnet_id      = var.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}
