output "aws_lb_public_dns" {
  description = "AWS load balancer public DNS"
  value       = aws_lb.app_lb.dns_name
}
