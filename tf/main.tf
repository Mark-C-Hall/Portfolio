provider "aws" {
  region = var.region
}

data "aws_route53_zone" "zone" {
  name = "${var.app_name}"
}

data "aws_acm_certificate" "cert" {
  domain   = "${var.app_name}"
  statuses = ["ISSUED"]
}

resource "aws_s3_bucket" "portfolio" {
  bucket = "www.${var.app_name}"

  tags = {
    Name        = "Portfolio-Bucket"
    Environment = "Production"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "enforce_object_ownership" {
  bucket = aws_s3_bucket.portfolio.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront_distribution" {
  bucket = aws_s3_bucket.portfolio.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_distribution.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_distribution" {
  statement {
    sid="AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.portfolio.arn}/*"]

    condition  {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.portfolio-distribution.arn]
    }
  }
}

resource "aws_s3_bucket" "root-portfolio" {
  bucket = "${var.app_name}"

  tags = {
    Name        = "Root-Portfolio-Bucket"
    Environment = "Production"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "root-enforce_object_ownership" {
  bucket = aws_s3_bucket.root-portfolio.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "root-block_public_access" {
  bucket = aws_s3_bucket.root-portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "root-website-config" {
  bucket = aws_s3_bucket.root-portfolio.id

  redirect_all_requests_to {
    host_name = "www.${var.app_name}"
  }
}

resource "aws_s3_bucket_policy" "allow_root_access_from_cloudfront_distribution" {
  bucket = aws_s3_bucket.root-portfolio.id
  policy = data.aws_iam_policy_document.allow_root_access_from_cloudfront_distribution.json
}

data "aws_iam_policy_document" "allow_root_access_from_cloudfront_distribution" {
  statement {
    sid="AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.root-portfolio.arn}/*"]

    condition  {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.root-portfolio-distribution.arn]
    }
  }
}

resource "aws_cloudfront_distribution" "portfolio-distribution" {
  origin {
    domain_name              = aws_s3_bucket.portfolio.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = aws_s3_bucket.portfolio.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["www.${var.app_name}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.portfolio.bucket_regional_domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = data.aws_cloudfront_cache_policy.managed-cache-optimized.min_ttl
    default_ttl            = data.aws_cloudfront_cache_policy.managed-cache-optimized.default_ttl
    max_ttl                = data.aws_cloudfront_cache_policy.managed-cache-optimized.max_ttl
  }

  restrictions {
    geo_restriction{
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "Portfolio-Distribution"
    Environment = "Production"
    Terraform   = "True"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  description                       = "Default OAI Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "managed-cache-optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "managed-cache-disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "root-portfolio-distribution" {
  origin {
    domain_name              = aws_s3_bucket.root-portfolio.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = aws_s3_bucket.root-portfolio.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true

  aliases = ["${var.app_name}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.root-portfolio.bucket_regional_domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = data.aws_cloudfront_cache_policy.managed-cache-disabled.min_ttl
    default_ttl            = data.aws_cloudfront_cache_policy.managed-cache-disabled.default_ttl
    max_ttl                = data.aws_cloudfront_cache_policy.managed-cache-disabled.max_ttl
  }

  restrictions {
    geo_restriction{
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "Root-Portfolio-Distribution"
    Environment = "Production"
    Terraform   = "True"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.app_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.app_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.root-portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root-portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-ipv6" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.app_name}"
  type    = "AAAA"
  
  alias {
    name                   = aws_cloudfront_distribution.portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root-ipv6" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.app_name}"
  type    = "AAAA"
  
  alias {
    name                   = aws_cloudfront_distribution.root-portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root-portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}