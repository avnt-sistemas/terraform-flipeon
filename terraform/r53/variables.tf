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

