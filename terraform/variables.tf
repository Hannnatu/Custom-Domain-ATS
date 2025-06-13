variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Custom domain name to be used with CloudFront (apex/root domain)"
  type        = string
  default     = "🔴"  # e.g. "example.com"
}

variable "hosted_zone_id" {
  description = "Route53 hosted Zone ID for Route 53"
  type        = string
  default     = "🔴"  # e.g. "Z123456ABCDEFG"
}

variable "custom_subdomain" {
  description = "Optional subdomain for customer custom domains (e.g., jobs.example.com)"
  type        = string
  default     = ""  # Leave empty if not using subdomains
}

