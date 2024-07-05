provider "aws" {
  region = var.region
}

locals {
  domain = var.environment != "prod" ? "${var.environment}.${var.domain_name}" : var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id = var.dns_zone
  name    = "www.${local.domain}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "other_all" {
  zone_id = var.dns_zone
  name    = "*.${local.domain}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app" {
  zone_id = var.dns_zone
  name    = "*.app.${local.domain}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api" {
  zone_id = var.dns_zone
  name    = "*.api.${local.domain}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}