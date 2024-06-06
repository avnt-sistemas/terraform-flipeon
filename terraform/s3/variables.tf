variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "project_group" {
  type        = string
  description = "The project group name."
}

variable "expiration_days" {
  type        = number
  description = "Number of days for remove files (automatically)."
  nullable = true
  default = 365
}

variable "transition_days" {
  type        = number
  description = "Number of days for send to low cost bucket (automatically)."
  nullable = true
  default = 30
}