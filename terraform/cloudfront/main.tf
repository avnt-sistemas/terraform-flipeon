resource "aws_cloudfront_distribution" "main" {
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "Custom-${var.origin_domain_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "Custom-${var.origin_domain_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
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
    Name = var.origin_domain_name
    ProjectGroup = var.project_group
  }
}

