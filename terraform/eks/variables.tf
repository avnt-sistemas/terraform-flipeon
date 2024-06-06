variable "cluster_name" {
  description = "The name of the cluster"
  type = string
  
}

variable "cluster_version" {
  description = "The version of the cluster"
  type = string
  default = "1.21"
}

variable "instance_type" {
  description = "The instance type of the cluster"
  type = string
  default = "t3.medium"
  
}

variable "key_name" {
  description = "The key name of the cluster"
  type = string
}

variable "desired_capacity" {
  description = "The desired capacity of the cluster"
  type = number
  default = 2
}

variable "max_capacity" {
  description = "The max capacity of the cluster"
  type = number
  default = 3
}

variable "min_capacity" {
  description = "The min capacity of the cluster"
  type = number
  default = 1
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "subnet_ids" {
  description = "subnet_ids"
}

variable "control_plane_subnet_ids" {
  description = "control_plane_subnet_ids"
}

variable "source_security_group_ids" {
  description = "source_security_group_ids"
}



