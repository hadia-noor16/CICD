# Module to manage the static website files.

module "website_files" {
  source = "./website"
}

terraform{
    backend "s3" {
        
        bucket = "demo-s3-hadia"
        encrypt = true
        key = ".tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform_locks"
    }
}

# The s3 bucket for the (dev) environment.
resource "aws_s3_bucket" "hadia_dev_s3" {
  bucket = var.dev_bucket
}

# The policy for the (dev) s3 buket to allow public read access.

resource "aws_s3_bucket_policy" "dev_s3_policy" {
  depends_on = [aws_s3_bucket_public_access_block.dev_s3_public_access_block]  
  bucket = aws_s3_bucket.hadia_dev_s3.id

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
  bucket = aws_s3_bucket.hadia_dev_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# This block is uploading the files to the (dev) s3 bucket.

resource "aws_s3_object" "dev_s3_files" {
  bucket = aws_s3_bucket.hadia_dev_s3.id

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
  bucket = aws_s3_bucket.hadia_dev_s3.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# s3 bucket for the (prod) environment  
  
resource "aws_s3_bucket" "hadia_pro_s3" {
  bucket = var.pro_bucket
}

# Policy for the (prod) s3 bucket to allow public read access

resource "aws_s3_bucket_policy" "pro_s3_policy" {
  depends_on = [aws_s3_bucket_public_access_block.pro_s3_public_access_block]
  bucket = aws_s3_bucket.hadia_pro_s3.id

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
  bucket = aws_s3_bucket.hadia_pro_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# This block is uploading the files to the (prod) s3 bucket.

resource "aws_s3_object" "pro_s3_files" {
  bucket = aws_s3_bucket.hadia_pro_s3.id

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
  bucket = aws_s3_bucket.hadia_pro_s3.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.pro_bucket}-oac"
  description                       = "OAC for ${var.pro_bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
# This will define the origin which is the s3 bucket
origin {
    origin_id                = "s3-${var.pro_bucket}"
    domain_name = "${aws_s3_bucket.hadia_pro_s3.bucket_regional_domain_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
}

# Enable the distribution and configure basic settings
enabled             = true
  is_ipv6_enabled     = true
  comment             = "mydevopslife"
  default_root_object = "index.html"



# Default cache behavior settings
default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${var.pro_bucket}"

# The settings for forwarding requests
forwarded_values {
      query_string = false
cookies {
        forward = "none"
      }
    }
viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  
# Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-${var.pro_bucket}"
forwarded_values {
      query_string = false
      headers      = ["Origin"]
cookies {
        forward = "none"
      }
    }
min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
  
# Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id  = "s3-${var.pro_bucket}"
forwarded_values {
      query_string = false
cookies {
        forward = "none"
      }
    }
min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress             = true
    viewer_protocol_policy = "redirect-to-https"
  }

# Pricing class for the distribution 
price_class = "PriceClass_200"
restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }
tags = {
    Environment = "production"
  }

# SSL/TLS cerificate settings

viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# s3 srtifacts bucket for ci/cd pipeline
resource "aws_s3_bucket" "artifacts" {
  bucket = "hn-artifacts123"
}
resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "acl" {
  bucket = aws_s3_bucket.artifacts.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "s3_policy" {
  depends_on = [aws_s3_bucket_public_access_block.acl]
  bucket = aws_s3_bucket.artifacts.id
 
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : ["${aws_s3_bucket.artifacts.arn}/*"]
      }
    ]
  })
}


# Service role for CodeBuild and assume role

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }


  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection"
    ]
    resources = ["arn:aws:codeconnections:us-east-1:957196010799:connection/05fcb4eb-3c4f-42d6-910a-b6474474cdd6"]
  }
}

resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.example.name
  policy = data.aws_iam_policy_document.example.json
}



# CI/CD Build phase with github repo as source, defining where build project artifacts go to in s3 bucket, and the specs of server to run this task

resource "aws_codebuild_project" "project" {
  name          = "my-codebuild-project"
  description   = "Build project for my website"
  service_role  = aws_iam_role.example.arn
  source {
    type      = "GITHUB"
    location  = "https://github.com/hadia-noor16/CICD/website"
    buildspec = "buildspec.yml"  
  }
  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.id
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
 }
}



# Code pipeline with source, build, and deploy stage (to s3 dev bucket)
resource "aws_codepipeline" "pipeline" {
  name     = "my-pipeline"
  role_arn = aws_iam_role.codepipelinerole.arn
artifact_store {
    location = aws_s3_bucket.artifacts.id
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn = var.github_connector  # create variable and save the connector name in .tfvars file
        FullRepositoryId = "hadia-noor16/CICD"  # Update with your GitHub repo name
        BranchName = "main"  # Specify the branch
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.project.name
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["build_output"]
      configuration = {
        BucketName = var.dev_bucket  # my dev bucket
        Extract    = "true"
      }
    }
  }
}

# CodePipeline role

data "aws_iam_policy_document" "assume_role_pipeline" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role"  "codepipelinerole" {
  name = "codepipelinerole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_pipeline.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.github_connector]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "codepipelinerole" {
  role   = aws_iam_role.codepipelinerole.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}