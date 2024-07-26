output "sqs_queue_id" {
  description = "The ID of the SQS queue"
  value       = aws_sqs_queue.new_queue.id
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.new_queue.arn
}
