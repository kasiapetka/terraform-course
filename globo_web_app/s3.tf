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
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-allow-nginx" })

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
        "AWS": "${data.aws_elb_service_account.root.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
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
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
    }
  ]
}
    POLICY
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name =  "${local.name_prefix}-allow_s3_all" 
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
        Resource = ["arn:aws:s3:::${local.s3_bucket_name}",
        "arn:aws:s3:::${local.s3_bucket_name}/*"]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${local.name_prefix}-nginx_profile" 
  role = aws_iam_role.allow_nginx_s3.name
  tags = local.common_tags
}

resource "aws_s3_bucket" "globo_s3" {
  bucket = local.s3_bucket_name

  force_destroy = true
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-s3" })
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.globo_s3.id
  acl    = "private"
}

resource "aws_s3_object" "website_content" {
  for_each = {
    "website" = "/website/index.html"
    "logo"    = "/website/Globo_logo_Vert.png"
  }
  bucket = aws_s3_bucket.globo_s3.bucket
  key    = each.value
  source = ".${each.value}"
  tags   = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}" })
}

