output "load_balancer_dns_name" {
  value = aws_lb.application.dns_name
}

output "load_balancer_zone_id" {
  value = aws_lb.application.zone_id
}

output "load_balancer_target_group" {
  value = aws_lb_target_group.application.arn
}