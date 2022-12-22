data "aws_route53_zone" "zone" {
  name = var.app_name
}

data "aws_acm_certificate" "cert" {
  domain   = var.app_name
  statuses = ["ISSUED"]
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
  name    = var.app_name
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
  name    = var.app_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.root-portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root-portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}