provider "aws" {
  region = var.region
}

locals {
  domain = var.environment != "prod" ? "${var.environment}.${var.domain_name}" : var.domain_name
  suffix = "${var.project_name}-${var.environment}"
}

resource "aws_acm_certificate" "lb_cert" {
  domain_name       = local.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "crt-${local.suffix}"
    ProjectGroup = var.project_group
  }
}

data "aws_route53_zone" "primary" {
  name = var.domain_name
  private_zone = false

}

resource "aws_route53_record" "lb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.lb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

}

resource "aws_acm_certificate_validation" "lb_cert" {
  certificate_arn         = aws_acm_certificate.lb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.lb_cert_validation : record.fqdn]

  depends_on = [ aws_route53_record.lb_cert_validation ]
}

resource "aws_lb" "application" {
  name               = "lb-${local.suffix}"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-lb-${var.environment}"
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
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }

  certificate_arn = aws_acm_certificate.lb_cert.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}
