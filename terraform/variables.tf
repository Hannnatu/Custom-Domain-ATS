variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Custom domain name to be used with CloudFront"
  type        = string
  default     = "yourdomain.com" # 🔴 Replace with your domain
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID for Route 53"
  type        = string
  default     = "Z123456ABCDEFG" # 🔴 Replace with your hosted zone ID
}

