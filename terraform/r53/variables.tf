variable "environment" {
  description = "The environment of Project"
  type        = string
}

variable "lb_dns_name" {
  description = "The DNS name of the load balancer"
  type        = string
}

variable "lb_zone_id" {
  description = "The zone ID of the load balancer"
  type        = string
}

variable "domain_name" {
  description = "The domain name of project"
  type        = string
  default     = "flipeon.com"
}