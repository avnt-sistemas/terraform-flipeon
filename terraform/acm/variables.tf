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

variable "dns_zone" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}

variable "domain_name" {
  description = "The domain name of Route 53 hosted zone"
  type        = string
}