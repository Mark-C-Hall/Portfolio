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
    sid = "AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.portfolio.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.portfolio-distribution.arn]
    }
  }
}

resource "aws_s3_bucket" "root-portfolio" {
  bucket = var.app_name

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