resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "S3-OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "my-private-api"
  description = "Private REST API"
  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

resource "aws_cloudfront_distribution" "staging" {
  enabled                    = true
  is_staging_distribution    = true

  origin {
    domain_name             = aws_s3_bucket.staging.bucket_regional_domain_name
    origin_id               = "staging-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    domain_name             = aws_api_gateway_deployment.prod.invoke_url
    origin_id               = "api-gateway"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = "staging-s3"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    forwarded_values {
      query_string           = false
      cookies {
        forward               = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = "api-gateway"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "POST", "OPTIONS"]
    cached_methods           = ["GET", "OPTIONS"]
    cache_policy_id          = "413fdccd-de29-4fa8-b70f-bc3cb39d8ed4" # CachingDisabled
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # AllViewer
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type       = "none"
    }
  }

  default_root_object        = "index.html"
}

resource "aws_cloudfront_distribution" "primary" {
  enabled = true

  origin {
    domain_name             = aws_s3_bucket.prod.bucket_regional_domain_name
    origin_id               = "prod-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    domain_name             = aws_api_gateway_deployment.prod.invoke_url
    origin_id               = "api-gateway"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = "prod-s3"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    forwarded_values {
      query_string           = false
      cookies {
        forward               = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = "api-gateway"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "POST", "OPTIONS"]
    cached_methods           = ["GET", "OPTIONS"]
    cache_policy_id          = "413fdccd-de29-4fa8-b70f-bc3cb39d8ed4" # CachingDisabled
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # AllViewer
  }

  aliases                   = [var.domain_name]

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type       = "none"
    }
  }

  default_root_object        = "index.html"
}
