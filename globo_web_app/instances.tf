resource "aws_instance" "nginx_instances" {
  count                  = var.instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_sizes.small
  subnet_id              = aws_subnet.subnets[(count.index % var.vpc_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on = [
    aws_iam_role_policy.allow_s3_all
  ]
  user_data = templatefile("${path.module}/startup-script.tpl", {
    bucket_name = aws_s3_bucket.globo_s3.id
  })

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-nginx${count.index}" })
}
