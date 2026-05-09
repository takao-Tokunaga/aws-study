resource "aws_cloudfront_distribution" "cf" {
    origin {
        domain_name = aws_lb.alb.dns_name
        origin_id   = "alb-origin"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    enabled = true

    // REST APIはキャッシュ無効 - すべてのメソッド・クエリ文字列・ヘッダーをオリジンへ転送
    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "alb-origin"

        forwarded_values {
            query_string = true
            headers      = ["Accept", "Authorization", "Content-Type", "Origin"]
            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 0
        max_ttl                = 0
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        Name = "takao-case2-1-cf"
    }
}
