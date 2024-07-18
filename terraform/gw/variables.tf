variable "project_group" {
  description = "The name of Project Group for add management tags"
  type        = string
}

variable "project_name" {
  description = "The name of project"
  type        = string
}
variable "vpc_id" {
  description = "The VPC ID where the ECS cluster will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "The public subnets list"
}