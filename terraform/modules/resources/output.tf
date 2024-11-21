output "s3_bucket_website_url" {
  value       = "https://${aws_s3_bucket.static_site.website_endpoint}"
  description = "The website endpoint URL of the S3 bucket"
}