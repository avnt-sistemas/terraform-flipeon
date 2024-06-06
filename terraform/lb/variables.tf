variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnet"
}

variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  type        = string
}
variable "environment" {
  description = "The environment of Project"
  type        = string
}

variable "project_name" {
  description = "The name of project"
  type        = string
}

variable "project_group" {
  description = "The project group name"
  type        = string
}