
resource "aws_cloudwatch_log_group" "aws_cloudwatch" {
  name = var.log_group_name

  retention_in_days = var.retention_in_days
}