resource "aws_cloudfront_distribution" "cf" {
    origin {
        domain_name = aws_lb.alb.dns_name
        origin_id = "alb-origin"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "http-only"  // ALBへHTTPで転送
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    enabled = true

    ordered_cache_behavior {
        path_pattern     = "/wp-content/*"
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "alb-origin"  

        forwarded_values {
            query_string = false
            cookies { forward = "none" }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 86400
        max_ttl                = 31536000
    }

    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "alb-origin"

        forwarded_values {
            query_string = true
            headers      = ["Host", "X-Forwarded-Proto"] 
            cookies {
                forward = "all" // WordPressのセッションCookieを通す
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl     = 0
        default_ttl = 0
        max_ttl     = 0
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
            locations        = []  
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true // CloudFrontのデフォルト証明書
    }

    tags = {
        Name = "takao-case2-cf"
    }
}