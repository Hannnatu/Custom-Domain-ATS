output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}/submit"
}

