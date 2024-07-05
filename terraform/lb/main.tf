provider "aws" {
  region = var.region
}

locals {
  suffix = "${var.project_name}-${var.environment}"
}

resource "aws_lb" "application" {
  name               = "lb-${local.suffix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name         = "${var.project_name}-lb-${var.environment}"
    ProjectGroup = var.project_group
  }

  enable_http2 = true
}

resource "aws_lb_target_group" "application" {
  name        = "tg-lb-${local.suffix}"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }

  certificate_arn = var.certificate_arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}
