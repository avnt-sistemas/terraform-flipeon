resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.cluster_name}-execution-role"
  
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


output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
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
