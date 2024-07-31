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

  access_logs {
    bucket = var.logs_bucket
  }

  tags = {
    Name         = "${var.project_name}-lb-${var.environment}"
    ProjectGroup = var.project_group
  }

  enable_http2 = true
}

resource "aws_lb_target_group" "app" {
  name        = "tg-app-${local.suffix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" 

  health_check {
    path                = "/sign-in"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name         = "${var.project_name}-tg-app-${var.environment}"
    ProjectGroup = var.project_group
  }
}

resource "aws_lb_target_group" "api" {
  name        = "tg-api-${local.suffix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/status"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name         = "${var.project_name}-tg-api-${var.environment}"
    ProjectGroup = var.project_group
  }
}


resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.application.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }

  certificate_arn = var.certificate_arn
}

resource "aws_lb_listener" "http" {
  count = var.certificate_arn != "" ? 1 : 0
  
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "http2" {
  count = var.certificate_arn != "" ? 0 : 1

  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http2[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    host_header {
      values = ["app.${var.domain_name}"]
    }
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http2[0].arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    host_header {
      values = ["api.${var.domain_name}"]
    }
  }
}
