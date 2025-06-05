provider "aws" {
  region = "us-east-1"
}

variable "domain_name" {
  default = "yourdomain.com"
}

variable "hosted_zone_id" {
  default = "Z123456ABCDEFG"
}

# ---------------- S3 Bucket ----------------
resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "bucket" {
  bucket = "simple-domain-frontend-${random_id.bucket_id.hex}"
  force_destroy = true
  acl = "private"
}

# CloudFront OAI
resource "aws_cloudfront_origin_access_identity" "oai" {}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Effect = "Allow",
      Principal = { AWS = aws_cloudfront_origin_access_identity.oai.iam_arn },
      Action = "s3:GetObject",
      Resource = "${aws_s3_bucket.bucket.arn}/*"
    }]
  })
}

# Upload index.html
resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "../frontend/index.html"
  content_type = "text/html"
}

# ---------------- Lambda + API Gateway ----------------
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action: "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_dynamodb_table" "domains" {
  name         = "domains"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "domain"
  attribute {
    name = "domain"
    type = "S"
  }
}

resource "aws_lambda_function" "api" {
  function_name = "domain_api"
  filename      = "lambda.zip"
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.domains.name
    }
  }

  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda-domain-api-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when Lambda errors exceed 0"
  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }
}

# Lambda API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "domain-api"
}

resource "aws_api_gateway_resource" "submit" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "submit"
}

resource "aws_api_gateway_method" "submit_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_submit" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.submit.id
  http_method             = aws_api_gateway_method.submit_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.lambda_submit]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

# ---------------- ACM, CloudFront, DNS ----------------
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# CloudFront logging bucket
resource "aws_s3_bucket" "logging" {
  bucket = "cf-logging-${random_id.bucket_id.hex}"
  acl    = "log-delivery-write"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  logging_config {
    bucket = "${aws_s3_bucket.logging.bucket}.s3.amazonaws.com"
    prefix = "logs/"
    include_cookies = false
  }

  default_cache_behavior {
    target_origin_id       = "s3origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [var.domain_name]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

