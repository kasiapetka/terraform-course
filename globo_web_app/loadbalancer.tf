
data "aws_elb_service_account" "root" {}

resource "aws_lb" "app_lb" {
  name               =  "${local.name_prefix}-globo-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnets[*].id]

  enable_deletion_protection = false

  tags = local.common_tags

  access_logs {
    bucket  = aws_s3_bucket.globo_s3.bucket
    prefix  = "alb-logs"
    enabled = true
  }

}

resource "aws_lb_target_group" "app_lb_tg" {
  name     = "${local.name_prefix}-globo-app-lb-tg" 
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
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
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.app_lb_tg.arn
  target_id        = aws_instance.nginx_instances[count.index].id
  port             = 80
}
