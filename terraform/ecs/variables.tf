variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ECS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ECS service"
  type        = list(string)
}

variable "desired_capacity" {
  description = "The desired number of ECS service tasks"
  type        = number
}

variable "max_capacity" {
  description = "The maximum number of ECS service tasks"
  type        = number
}

variable "task_cpu" {
  description = "The number of cpu units used by the task"
  type        = string
}

variable "task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "source_security_group_ids" {
  description = "source_security_group_ids"
}