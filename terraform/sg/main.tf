resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # cidr_blocks ou source_security_group_ids deve ser especificado
    cidr_blocks = ["0.0.0.0/0"]
    # Caso você queira limitar o acesso ao RDS apenas de um grupo específico:
    # source_security_group_id = aws_security_group.ecs.id
  }

  
  tags = {
    Name         = "rds-security-group"
    ProjectGroup = var.project_group
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-security-group"
  description = "Security group for ECS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  tags = {
    Name         = "ecs-security-group"
    ProjectGroup = var.project_group
  }
}
