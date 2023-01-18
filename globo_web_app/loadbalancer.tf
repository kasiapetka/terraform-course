
data "aws_elb_service_account" "root" {}

resource "aws_lb" "app_lb" {
  name               = "${local.name_prefix}-applb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = local.common_tags

  access_logs {
    bucket  = module.globo-web-app-s3.web_bucket.id
    prefix  = "alb-logs"
    enabled = true
  }

}

resource "aws_lb_target_group" "app_lb_tg" {
  name     = "${local.name_prefix}-applb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  tags     = local.common_tags
}

resource "aws_lb_listener" "globo-app" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_lb_tg-atts" {
  count            = var.instance_count[terraform.workspace]
  target_group_arn = aws_lb_target_group.app_lb_tg.arn
  target_id        = aws_instance.nginx_instances[count.index].id
  port             = 80
}
