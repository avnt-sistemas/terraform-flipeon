variable "origin_domain_name" {
  description = "The domain name of the origin server"
  type        = string
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
  type        = string
}


variable "project_group" {
  description = "A map of tags to assign to the resource"
  type        = string
}
