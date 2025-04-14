output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.tech_radar.website_endpoint
  description = "S3 website endpoint"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.tech_radar.domain_name
  description = "CloudFront distribution domain name"
}

output "domain_name" {
  value       = local.domain_name
  description = "Tech Radar custom domain name"
}
