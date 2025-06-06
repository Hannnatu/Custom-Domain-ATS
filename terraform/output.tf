output "s3_bucket_name" {
  description = "S3 bucket name serving the site"
  value       = aws_s3_bucket.bucket.bucket
}

output "cloudfront_domain" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "api_gateway_invoke_url" {
  description = "Invoke URL for API Gateway (needs to be constructed)"
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}/submit"  # may need adjustment based on setup
}

