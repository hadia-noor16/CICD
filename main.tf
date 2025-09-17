# Module to manage the static website files.

module "website_files" {
  source = "./website"
}

# The s3 bucket for the (dev) environment.
resource "aws_s3_bucket" "dev_s3" {
  bucket = var.dev_bucket
}

# The policy for the (dev) s3 buket to allow public read access.

resource "aws_s3_bucket_policy" "dev_s3_policy" {
  depends_on = [aws_s3_bucket_public_access_block.dev_s3_public_access_block]  
  bucket = aws_s3_bucket.dev_s3.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.dev_bucket}/*"
      }
    ]
  })
}

# Configuring the (dev) s3 bucket as a static website.

resource "aws_s3_bucket_website_configuration" "dev_s3_website_configuration" {
  bucket = aws_s3_bucket.dev_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# This block is uploading the files to the (dev) s3 bucket.

resource "aws_s3_object" "dev_s3_files" {
  bucket = aws_s3_bucket.dev_s3.id

  for_each = {
    "index.html" = {
      key          = "index.html"
      source_path  = "website/index.html"
      content_type = "text/html"
    }
    "error.html" = {
      key          = "error.html"
      source_path  = "website/error.html"
      content_type = "text/html"
    }
  }
  key          = each.key
  source       = each.value.source_path
  content_type = each.value.content_type
}
  
# Configuring public access settings for the (dev) s3 bucket

resource "aws_s3_bucket_public_access_block" "dev_s3_public_access_block"{
  bucket = aws_s3_bucket.dev_s3.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# s3 bucket for the (prod) environment  
  
resource "aws_s3_bucket" "pro_s3" {
  bucket = var.pro_bucket
}

# Policy for the (prod) s3 bucket to allow public read access

resource "aws_s3_bucket_policy" "pro_s3_policy" {
  depends_on = [aws_s3_bucket_public_access_block.pro_s3_public_access_block]
  bucket = aws_s3_bucket.pro_s3.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.pro_bucket}/*"
      }
    ]
  })
}

# Configuring the (prod) s3 bucket as a static website

resource "aws_s3_bucket_website_configuration" "pro_s3_website_configuration" {
  bucket = aws_s3_bucket.pro_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# This block is uploading the files to the (prod) s3 bucket.

resource "aws_s3_object" "pro_s3_files" {
  bucket = aws_s3_bucket.pro_s3.id

  for_each = {
    "index.html" = {
      key          = "index.html"
      source_path  = "website/index.html"
      content_type = "text/html"
    }
    "error.html" = {
      key          = "error.html"
      source_path  = "website/error.html"
      content_type = "text/html"
    }
  }
  key          = each.key
  source       = each.value.source_path
  content_type = each.value.content_type
}

# Configuring public access settings for the (prod) s3 bucket

resource "aws_s3_bucket_public_access_block" "pro_s3_public_access_block"{
  bucket = aws_s3_bucket.pro_s3.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}