variable "environment" {
  description = "The environment of Project"
  type        = string
  default     = "dev"
}

variable "project_group" {
  description = "The name of Project Group for add management tags"
  type        = string
  default     = "grp-flipeon-prod"
}

variable "project_name" {
  description = "The name of project"
  type        = string
  default     = "flipeon"
}

variable "domain_name" {
  description = "The domain name of project"
  type        = string
  default     = "flipeon.com"
}

variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-1" //"sa-east-1"
}

variable "use_eks" {
  description = "Set to true to use EKS and false to use ECS"
  type        = bool
  default     = false
}
  