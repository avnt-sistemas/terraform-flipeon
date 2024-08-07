variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_group" {
  description = "The project group"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID for the load balancer"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}

variable "logs_bucket" {
  description = "The logs bucket for the access logs"
  type        = string
}
  
variable "domain_name" {
  description = "The domain name of project"
  type        = string
  default     = "flipeon.com"
}
