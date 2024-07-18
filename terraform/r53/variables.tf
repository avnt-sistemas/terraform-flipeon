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

variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
}

variable "dns_zone" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}