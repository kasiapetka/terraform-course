resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags =var.common_tags

}

resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.globo_s3.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.elb_service_account_arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.bucket_name}"
    }
  ]
}
    POLICY
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name =  "${var.bucket_name}-allow_s3_all" 
  role = aws_iam_role.allow_nginx_s3.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = ["arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${var.bucket_name}-nginx_profile" 
  role = aws_iam_role.allow_nginx_s3.name
  tags = var.common_tags
}

resource "aws_s3_bucket" "globo_s3" {
  bucket = var.bucket_name

  force_destroy = true
  tags          = var.common_tags
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.globo_s3.id
  acl    = "private"
}
