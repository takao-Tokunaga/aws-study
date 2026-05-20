resource "aws_kms_key" "images" {
  description             = "${var.project} images bucket key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = { Name = "${var.project}-images-kms-key" }
}

resource "aws_kms_alias" "images" {
  name          = "alias/${var.project}-images"
  target_key_id = aws_kms_key.images.key_id
}

resource "aws_s3_bucket" "images" {
  bucket = "${var.project}-images-${random_id.suffix.hex}"

  tags = { Name = "${var.project}-images" }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# すべてのパブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SSE-KMS 暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.images.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CORS: presigned URL アップロード用
resource "aws_s3_bucket_cors_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}
