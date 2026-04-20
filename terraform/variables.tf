variable "acm_certificate_arn" {
  type        = string
  description = "ACM Certificate ARN for path-to.org from the host AWS account"
  sensitive   = true
}