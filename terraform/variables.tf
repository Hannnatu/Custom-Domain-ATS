# Variables to customize deployment

variable "domain_name" {
  description = "The custom domain to use"
  type        = string
  default     = "yourdomain.com"  # ● Replace with your actual domain or override this value when applying
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
  default     = "Z123456ABCDEFG"  # ● Replace with your actual Hosted Zone ID or override this value
}

