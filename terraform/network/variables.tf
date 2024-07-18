variable "environment" {
  description = "The environment of Project"
  type        = string
}

variable "region" {
  description = "The region of the VPC"
  type        = string
}

variable "project_name" {
  description = "The project name of the VPC"
  type        = string
}

variable "project_group" {
  description = "The project group of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "suffix_count" {
  description = "The number of suffixes to generate for AZs"
  type        = number
  default     = 3
}

variable "suffixes" {
  description = "List of availability zone suffixes"
  default     = ["a", "b", "c"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}