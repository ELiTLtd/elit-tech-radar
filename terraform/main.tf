# Tech Radar specific local values
locals {
  parent_domain = "englishlanguageitutoring.com"
  domain_name = "techradar.${local.parent_domain}"
  environment = "prod"
  
  # For CloudFront origin ID
  s3_origin_id = "S3-${local.domain_name}"
  
  # For the redirect configuration
  redirect_target = "radar.thoughtworks.com"
  radar_csv_path = "https://raw.githubusercontent.com/ELiTLtd/elit-tech-radar/main/radar.csv"
}

# S3 bucket for hosting the redirect - uses default provider (eu-west-1)
resource "aws_s3_bucket" "tech_radar" {
  bucket = local.domain_name
}

# Configure the bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "tech_radar" {
  bucket = aws_s3_bucket.tech_radar.id

  index_document {
    suffix = "index.html"
  }

  # Redirect all requests to ThoughtWorks radar with our CSV
  routing_rules = jsonencode([
    {
      Redirect = {
        HostName      = local.redirect_target
        Protocol      = "https"
        ReplaceKeyWith = "?documentId=${urlencode(local.radar_csv_path)}"
      }
    }
  ])
}

# Set public access settings for the bucket
resource "aws_s3_bucket_public_access_block" "tech_radar" {
  bucket = aws_s3_bucket.tech_radar.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Make the bucket content publicly accessible
resource "aws_s3_bucket_policy" "tech_radar_policy" {
  bucket = aws_s3_bucket.tech_radar.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.tech_radar.arn}/*"
      }
    ]
  })
}

# Create ACM certificate for the domain - MUST be in us-east-1 for CloudFront
resource "aws_acm_certificate" "tech_radar" {
  provider          = aws.us_east_1
  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront distribution - MUST be in us-east-1
resource "aws_cloudfront_distribution" "tech_radar" {
  provider = aws.us_east_1
  
  origin {
    domain_name = aws_s3_bucket_website_configuration.tech_radar.website_endpoint
    origin_id   = local.s3_origin_id
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Use only North America and Europe edge locations

  aliases = [local.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.tech_radar.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# Data source for the Route 53 zone - uses default provider
data "aws_route53_zone" "main" {
  name = "${local.parent_domain}."
}

# Route 53 record to point to CloudFront - uses default provider
resource "aws_route53_record" "tech_radar" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.tech_radar.domain_name
    zone_id                = aws_cloudfront_distribution.tech_radar.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route 53 record for certificate validation - uses default provider
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tech_radar.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Certificate validation - MUST be in us-east-1
resource "aws_acm_certificate_validation" "tech_radar" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.tech_radar.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
