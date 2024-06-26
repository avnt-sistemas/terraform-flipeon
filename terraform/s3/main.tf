resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
    ProjectGroup = var.project_group
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  count = var.expiration_days != null ? 1 : 0

  rule {
    id = "expire_old_objects"

    status = "Enabled"

    expiration {
      days = var.expiration_days
    }

    transition {
      days          = var.transition_days
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.bucket_name}/*"
        Condition = {
          StringEquals = {
            Referer = var.bucket_name
          }
        }
      },
    ]
  })
}