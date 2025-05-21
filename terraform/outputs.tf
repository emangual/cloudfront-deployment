output "cloudfront_primary_domain" {
  value = aws_cloudfront_distribution.primary.domain_name
}
