resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
    ProjectGroup = var.project_group
  }
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors" {
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]  # Substitua "*" por origens específicas, se necessário
    expose_headers   = []
    max_age_seconds  = 3000
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
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.bucket_policy_settings]
}

resource "aws_s3_bucket_public_access_block" "bucket_policy_settings" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_iam_role" "s3_ingestion_role" {
  name = "s3-ingestion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "s3-ingestion-role"
    ProjectGroup = var.project_group
  }
}

resource "aws_iam_policy" "s3_ingestion_policy" {
  name        = "s3-ingestion-policy"
  description = "Policy to allow RDS to access S3 for data ingestion"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_ingestion_attachment" {
  policy_arn = aws_iam_policy.s3_ingestion_policy.arn
  role     = aws_iam_role.s3_ingestion_role.name
}
