variable "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  type        = string
}

variable "retention_in_days" {
  description = "The number of days to retain logs"
  type        = number
}

variable "load_balancer_name" {
  description = "The name of the Load Balancer"
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