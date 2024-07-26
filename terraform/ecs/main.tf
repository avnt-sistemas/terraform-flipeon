data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Política para acessar o ECR
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${var.cluster_name}-ecr-access-policy"
  description = "Permissão para acessar o Amazon ECR"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# Anexar a política ECR à role ECS
resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# Política de execução da tarefa ECS
resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "${var.cluster_name}-ecs-task-execution-policy"
  role   = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.cluster_name}:*"
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.cluster_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = var.cluster_name
      image     = var.image
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.cluster_name}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = var.environment_vars
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = var.cluster_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.source_security_group_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.lb_target_group
    container_name   = var.cluster_name
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 7
}