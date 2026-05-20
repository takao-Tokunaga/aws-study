terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# メンテナンス中もアクセス許可する IP セット
resource "aws_wafv2_ip_set" "maintenance_allowlist" {
  name               = "${var.project}-maintenance-allowlist"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = length(var.maintenance_allowed_cidrs) > 0 ? var.maintenance_allowed_cidrs : ["127.0.0.1/32"]

  tags = { Name = "${var.project}-maintenance-allowlist" }
}

resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project}-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # メンテナンスモード: 許可 IP 以外をブロック
  dynamic "rule" {
    for_each = var.maintenance_mode ? [1] : []
    content {
      name     = "MaintenanceMode"
      priority = 1

      action {
        block {
          custom_response {
            response_code            = 503
            custom_response_body_key = "maintenance"
          }
        }
      }

      statement {
        not_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.maintenance_allowlist.arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "MaintenanceModeRule"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS マネージドルール: 一般的な脅威対策
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  custom_response_body {
    key          = "maintenance"
    content      = "<html><body><h1>メンテナンス中</h1><p>現在メンテナンス中です。しばらくお待ちください。</p></body></html>"
    content_type = "TEXT_HTML"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-waf"
    sampled_requests_enabled   = true
  }

  tags = { Name = "${var.project}-waf" }
}
