resource "aws_cloudfront_distribution" "main" {
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:457504760127:certificate/ddade52c-1cf3-4ad2-807a-5e309e35dbd2"
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

