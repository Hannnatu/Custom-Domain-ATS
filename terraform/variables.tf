variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Custom domain name to be used with CloudFront (apex/root domain)"
  type        = string
  default     = "yourdomain.com" # 🔴 Replace with chosen domain
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID for Route 53"
  type        = string
  default     = "Z123456ABCDEFG" # 🔴 Replace with hosted zone ID
}

variable "custom_subdomain" {
  description = "Optional subdomain for customer custom domains (e.g., jobs.mycompany.com)"
  type        = string
  default     = ""   # Leave empty if not using subdomains
}

