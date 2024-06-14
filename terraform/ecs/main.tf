module "ecs" {
  source = "sudo-terraform-aws-modules/ecs-container/aws"
  version = "~> 2.0"

  name = "${var.cluster_name}-cluster"

  vpc_id        = var.vpc_id
  subnet_ids    = var.subnet_ids

  create_ecs_cluster = true

  ecs_cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  ecs_services = {
    my_service = {
      desired_count = var.desired_capacity
      task_definition = "arn:aws:ecs:${var.region}:${var.account_id}:task-definition/${var.cluster_name}-service"
      launch_type = "FARGATE"
      network_configuration = {
        assign_public_ip = true
        subnets = var.subnet_ids
        security_groups = var.source_security_group_ids
      }
    }
  }

  ecs_task_definitions = {
    my_task = {
      container_definitions = jsonencode([
        {
          name  = "${var.cluster_name}-ecs-container"
          image = "amazon/amazon-ecs-sample"
          cpu   = var.container_cpu 
          memory = var.container_memory
          essential = true
          portMappings = [
            {
              containerPort = 80
              hostPort      = 80
            }
          ]
        }
      ])

      family = "${var.cluster_name}-ecs-family"
      requires_compatibilities = ["FARGATE"]
      network_mode = "awsvpc"
      cpu = var.task_cpu
      memory = var.task_memory
    }
  }
}
