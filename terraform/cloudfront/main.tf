provider "aws" {
  region = var.region
}

resource "aws_cloudfront_distribution" "main" {

  dynamic "viewer_certificate" {
    for_each = var.certificate_arn != "" ? [var.certificate_arn] : []
    content {
      acm_certificate_arn = var.certificate_arn
      ssl_support_method  = "sni-only"
    }
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "cf-${var.project_name}-${var.environment}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "cf-${var.project_name}-${var.environment}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = var.certificate_arn != "" ? "redirect-to-https" : "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name         = var.origin_domain_name
    ProjectGroup = var.project_group
  }
}
