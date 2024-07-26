resource "aws_sqs_queue" "new_queue" {
  name = var.queue_name
}
