variable "environment" {
  description = "The environment of Project"
  type        = string
  default     = "prod"
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

variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "sa-east-1"
}
  