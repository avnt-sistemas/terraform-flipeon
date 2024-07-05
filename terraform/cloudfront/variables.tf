variable "origin_domain_name" {
  description = "The domain name of the origin server"
  type        = string
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
  type        = string
}


variable "project_group" {
  description = "A project group to assign to the resource"
  type        = string
}

variable "project_name" {
  description = "A project name to assign to the resource"
  type        = string
}

variable "environment" {
  description = "An environment name to assign to the resource"
  type        = string
}

variable "certificate_arn" {
  description = "certificate_arn"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}