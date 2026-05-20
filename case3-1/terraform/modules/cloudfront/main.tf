# S3 アクセス用 OAC
resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.project}-s3-oac"
  description                       = "OAC for ${var.project} S3 images"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Signed URL 用キーグループ（画像配信に使用）
resource "aws_cloudfront_public_key" "images" {
  count       = var.cloudfront_public_key_pem != "" ? 1 : 0
  name        = "${var.project}-images-key"
  encoded_key = var.cloudfront_public_key_pem
  comment     = "Key for signed URL image access"
}

resource "aws_cloudfront_key_group" "images" {
  count   = var.cloudfront_public_key_pem != "" ? 1 : 0
  name    = "${var.project}-images-key-group"
  items   = [aws_cloudfront_public_key.images[0].id]
  comment = "Key group for signed URL image access"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  web_acl_id          = var.waf_acl_arn
  price_class         = "PriceClass_200"

  # Origin 1: ALB（フロントエンド + API）
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Origin 2: S3（プライベート画像）
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = "s3-images"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  # デフォルトキャッシュ: ALB（フロントエンド）
  default_cache_behavior {
    target_origin_id       = "alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Host", "Authorization", "Origin", "Accept", "CloudFront-Forwarded-Proto"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # /api/* キャッシュ無効（動的コンテンツ）
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # /images/* → S3（Signed URL 必須）
  ordered_cache_behavior {
    path_pattern           = "/images/*"
    target_origin_id       = "s3-images"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    trusted_key_groups = var.cloudfront_public_key_pem != "" ? [aws_cloudfront_key_group.images[0].id] : null

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Name = "${var.project}-cloudfront" }
}
