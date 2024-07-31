// Cria um grupo de logs do CloudWatch
resource "aws_cloudwatch_log_group" "aws_cloudwatch" {
  name              = var.log_group_name          // Nome do grupo de logs, definido na variável `log_group_name`
  retention_in_days = var.retention_in_days       // Dias de retenção dos logs, definido na variável `retention_in_days`

  
  tags = {
    Name         = "${var.log_group_name}-${var.environment}"
    ProjectGroup = var.project_group
  }
}

// Alarme para monitorar o tempo de resposta do ALB
resource "aws_cloudwatch_metric_alarm" "response_time_alarm" {
  alarm_name          = "alb-response-time"                          // Nome do alarme
  comparison_operator = "GreaterThanThreshold"                       // Operador de comparação
  evaluation_periods  = 1                                            // Períodos de avaliação
  metric_name         = "TargetResponseTime"                         // Nome da métrica
  namespace           = "AWS/ApplicationELB"                         // Namespace da métrica
  period              = 3600                                         // Período em segundos (1 hora)
  statistic           = "Average"                                    // Estatística utilizada
  threshold           = 1.0                                          // Limite para acionar o alarme
  alarm_description   = "Alarm when the average response time exceeds 1 second in the last hour" // Descrição do alarme
  dimensions = {
    LoadBalancer = var.load_balancer_name                            // Nome do Load Balancer, definido na variável `load_balancer_name`
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]                    // Ações do alarme (SNS topic ARN)
}

// SNS topic para enviar notificações de alarme
resource "aws_sns_topic" "alarm_topic" {
  name = "cloudwatch-alarms"
}

// Permissão para a função Lambda ser acionada pelo CloudWatch
resource "aws_lambda_permission" "alb_response_time_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alb_response_time_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alb_response_time_rule.arn
}

// Função Lambda para processar dados do ALB
resource "aws_lambda_function" "alb_response_time_lambda" {
  filename         = "path/to/your/lambda_function.zip"               // Caminho para o arquivo ZIP da função Lambda
  function_name    = "alb-response-time-function"                     // Nome da função Lambda
  role             = aws_iam_role.lambda_execution_role.arn           // ARN da role IAM
  handler          = "index.handler"                                  // Handler da função Lambda
  runtime          = "nodejs14.x"                                     // Runtime da função Lambda

  environment {
    variables = {
      LOAD_BALANCER_NAME = var.load_balancer_name                     // Nome do Load Balancer, definido na variável `load_balancer_name`
      IDENTIFIER = "${var.log_group_name}-${var.environment}"         // Tag para identificar o ambiente, definida na variável `tag`
    }
  }
}

// Role IAM para a função Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

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
}

// Políticas IAM para a função Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
