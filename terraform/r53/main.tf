locals {
  domain = var.environment != "prod" ? "${var.environment}.flipeon.com" : "flipeon.com"
}

resource "aws_route53_zone" "primary" {
  name = "flipeon.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${local.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_load_balancer.dns_name
    zone_id                = aws_lb.ecs_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "other_all" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "*.${local.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_load_balancer.dns_name
    zone_id                = aws_lb.ecs_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "*.app.${local.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_load_balancer.dns_name
    zone_id                = aws_lb.ecs_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "*.api.${local.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_load_balancer.dns_name
    zone_id                = aws_lb.ecs_load_balancer.zone_id
    evaluate_target_health = true
  }
}