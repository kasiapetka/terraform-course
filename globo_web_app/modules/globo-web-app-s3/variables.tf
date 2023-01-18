variable "bucket_name" {
  type        = string
  description = "AWS S3 bucket name"
}

variable "elb_service_account_arn" {
  type        = string
  description = "ELB AWS Service account arn"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}
