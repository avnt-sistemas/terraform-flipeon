variable "region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "domain_name" {
  description = "The domain name of project"
  type        = string
  default     = "flipeon.com"
}

variable "security_group_id" {
  description = "The ID of the security group"
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

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}
