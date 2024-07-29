resource "aws_lambda_function" "upload_lambda" {
  filename         = var.filename
  function_name    = var.function_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256(var.filename)
  runtime          = var.runtime
  environment {
    variables = {
      SQS_QUEUE_URL = var.queue_id
      DEST_S3_BUCKET = "docs-bucket-flipeon-dev"
      FLIPEON_API    = var.api_endpoint
    }
  }
}

resource "aws_lambda_permission" "allow_sqs" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_lambda.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.queue_arn
}

resource "aws_sqs_queue_policy" "allow_lambda" {
  queue_url = var.queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action    = "SQS:SendMessage"
        Resource  = var.queue_id
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "upload_lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "${var.function_name}-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
          ]
          Resource = "*"
        }
      ]
    })
  }
}