output "s3_bucket_website_url" {
  value       = "http://${aws_s3_bucket.static_site.website_endpoint}"
  description = "The website endpoint URL of the S3 bucket (HTTP)"
}

output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
  description = "CloudFront HTTPS URL del frontend"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.frontend.id
  description = "ID de la distribución CloudFront"
}