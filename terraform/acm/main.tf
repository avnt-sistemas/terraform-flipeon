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

  subject_alternative_names = [
    "www.${var.domain_name}",
    "*.app.${local.domain}",
    "*.api.${local.domain}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name         = "crt-${local.suffix}"
    ProjectGroup = var.project_group
  }
}

resource "aws_route53_record" "lb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.lb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.dns_zone
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "lb_cert" {
  certificate_arn         = aws_acm_certificate.lb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.lb_cert_validation : record.fqdn]
}
