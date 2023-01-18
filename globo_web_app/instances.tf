resource "aws_instance" "nginx_instances" {
  count                  = var.instance_count[terraform.workspace]
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_sizes[terraform.workspace]
  subnet_id              = module.vpc.public_subnets[(count.index % var.vpc_subnet_count[terraform.workspace])]
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = module.globo-web-app-s3.instance_profile.name
  depends_on = [
    module.globo-web-app-s3
  ]
  user_data = templatefile("${path.module}/startup-script.tpl", {
    bucket_name = module.globo-web-app-s3.web_bucket.id
  })

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-nginx${count.index}" })
}
