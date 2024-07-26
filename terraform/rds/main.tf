resource "random_password" "db_password" {
  length           = 16
  special          = false
}

resource "aws_db_instance" "db_writer" {
  identifier              = "${var.db_identifier}-writer"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db_password.result
  port                    = var.db_port
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = var.database_subnet_group

  storage_type = var.db_engine != "aurora-postgresql" ? null : "aurora"

  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_engine == "aurora-postgresql" ? null : var.db_max_allocated_storage
  iops                    = var.db_engine != "aurora-postgresql" ? null : 1000

  apply_immediately = true

  skip_final_snapshot = true
  
  backup_retention_period = 7
  
  publicly_accessible = true

  tags = {
    Name         = "${var.db_identifier}-writer"
    ProjectGroup = var.project_group
  }
}

# resource "aws_db_instance" "db_reader" {
#   identifier           = "${var.db_identifier}-reader"
#   engine               = var.db_engine
#   engine_version       = var.db_engine_version
#   instance_class       = var.db_reader_instance_class
  
#   replicate_source_db  = aws_db_instance.db_writer.identifier
  
#   allocated_storage       = var.db_allocated_storage
#   max_allocated_storage   = var.db_engine == "aurora-postgresql" ? null : var.db_max_allocated_storage
#   iops                    = var.db_engine != "aurora-postgresql" ? null : 1000

#   apply_immediately = true
#   skip_final_snapshot = true

#   tags = {
#     Name         = "${var.db_identifier}-reader"
#     ProjectGroup = var.project_group
#   }

#   depends_on = [ aws_db_instance.db_writer ]
# }

resource "local_file" "db_password_file" {
  filename = "${path.module}/db_password.txt"
  content  = random_password.db_password.result
}