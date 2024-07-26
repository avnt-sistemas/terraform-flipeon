variable "filename" {
  description = "The path to the Lambda function .zip file"
  type        = string
}


variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "queue_id" {
  description = "The ID of the SQS queue"
  type        = string
}

variable "queue_arn" {
  description = "The ARN of the SQS queue"
  type        = string
}

variable "api_endpoit" {
  description = "The ARN of the SQS queue"
  type        = string
}
