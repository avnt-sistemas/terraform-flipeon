variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_port" {
  description = "The name of the database"
  type        = number
  default     = 5432
}

variable "db_username" {
  description = "The master username for the database"
  type        = string
}


variable "db_family" {
  description = "The engine for the database"
  type        = string
  default     = "postgres12"
}

variable "db_engine" {
  description = "The engine for the database"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The engine version for the database"
  type        = string
  default     = "12"
}

variable "db_reader_instance_class" {
  description = "The instance type for the database"
  type        = string
  default     = "db.t3.small"
}

variable "db_instance_class" {
  description = "The instance type for the database"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the database"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "The allocated storage for the database"
  type        = number
  default     = 100
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "database_subnet_group" {
  description = "database_subnet_group"
}

variable "project_group" {
  description = "The project group name"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ECS service"
  type        = list(string)
}

variable "load_balancer_security_group" {
  description = "load_balancer_security_group"
}


