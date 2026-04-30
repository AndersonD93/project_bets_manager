resource "aws_s3_bucket" "static_site" {
  bucket = var.s3_list_name["bucket_host"]

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static_site.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  react_build_dir = "${path.module}/../../../frontend/dist"

  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain"
  }
}

resource "aws_s3_object" "react_build" {
  for_each = fileset(local.react_build_dir, "**")

  bucket       = aws_s3_bucket.static_site.bucket
  key          = each.value
  source       = "${local.react_build_dir}/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")
  etag         = filemd5("${local.react_build_dir}/${each.value}")
}

resource "aws_s3_object" "dashboard_html" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "html/dashboard.html"
  source       = "${path.module}/../../templates/html/dashboard.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../../templates/html/dashboard.html")
}