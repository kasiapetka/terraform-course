output "web_bucket" {
  value = aws_s3_bucket.globo_s3
}

output "instance_profile" {
  value = aws_iam_instance_profile.nginx_profile
}

