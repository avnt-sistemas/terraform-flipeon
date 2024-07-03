resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier        = "${var.db_identifier}-writer"
  
  family = var.db_family
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  major_engine_version = var.db_engine_version
  instance_class    = var.db_instance_class
  
  allocated_storage = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  
  db_name           = var.db_name
  username          = var.db_username
  password          = random_password.db_password.result
  port              = var.db_port
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = var.database_subnet_group
  skip_final_snapshot    = true
  
}

resource "aws_db_instance" "db_reader" {
  identifier        = "${var.db_identifier}-reader"
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_reader_instance_class
  allocated_storage = var.db_allocated_storage
  
  db_name           = var.db_name
  username          = var.db_username
  password          = random_password.db_password.result
  port              = var.db_port
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = var.database_subnet_group

  # Configuração da instância de leitura
  replicate_source_db = module.db.db_instance_id
}

resource "local_file" "db_password_file" {
  filename = "${path.module}/db_password.txt"
  content  = random_password.db_password.result
}


resource "aws_security_group" "rds" {
  name        = "allow-rds-access"
  description = "Allow access to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}