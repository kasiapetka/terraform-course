variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix fo all resources"
  default     = "globoweb"
}

variable "aws_instance_sizes" {
  type        = map(string)
  description = "AWS instance sizes"
  default = {
    small  = "t2.micro"
    medium = "t2.small"
    large  = "t2.large"
  }
}

variable "vpc_subnet_count" {
  type        = number
  description = "Number of subnets in VPC"
  default     = 2
}

variable "instance_count" {
  type        = number
  description = "Number of instances"
  default     = 2
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC in AWS networking"
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "DNS hostnames enable for VPC in AWS networking"
  default     = true
}

variable "vpc_subnets_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for subnets in AWS networking"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map public IP on launch in AWS networking subnet"
  default     = true
}

variable "company" {
  type        = string
  description = "Company name"
  default     = "Globomantics"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
}
