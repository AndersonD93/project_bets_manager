resource "aws_s3_bucket" "static_site" {
  bucket = var.s3_list_name["bucket_host"]

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static_site.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.static_site.bucket
  policy = data.aws_iam_policy_document.allow_access_from_another_principal.json
}

data "aws_iam_policy_document" "allow_access_from_another_principal" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.static_site.arn}/*",
    ]
  }
}

resource "aws_s3_object" "html_files" {
  for_each     = fileset("${path.module}/../../templates/html", "*.html")
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "html/${each.value}"
  source       = "${path.module}/../../templates/html/${each.value}"
  content_type = "text/html"
}

resource "aws_s3_object" "css_files" {
  for_each     = fileset("${path.module}/../../templates/css", "*.css")
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "css/${each.value}"
  source       = "${path.module}/../../templates/css/${each.value}"
  content_type = "text/css"
}

resource "aws_s3_object" "js_files" {
  for_each     = fileset("${path.module}/../../templates/js", "*.js")
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "js/${each.value}"
  source       = "${path.module}/../../templates/js/${each.value}"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/../../templates/js/${each.value}")
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "index.html"
  source       = "${path.module}/../../templates/index.html"
  content_type = "text/html"
}

