# This is the output for the URL of the (dev) static website.

output "dev_website_url" {
  description = "URL of the dev website"
  value       = aws_s3_bucket_website_configuration.dev_s3_website_configuration.website_endpoint
}

# This is the output for the URL of the (prod) static website.

output "prod_website_url" {
  description = "URL of the pro website"
  value       = aws_s3_bucket_website_configuration.pro_s3_website_configuration.website_endpoint
}

# The output for the path to the index.html file within the module.

output "index_path" {
  value = "${path.module}/index.html"
}

# The output for the path to the error.html file within the module.

output "error_path" {
  value = "${path.module}/error.html"
}