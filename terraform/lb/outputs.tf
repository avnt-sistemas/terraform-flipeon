output "load_balancer_arn" {
  value = aws_lb.application.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.application.arn
}

output "load_balancer_dns_name" {
  value = aws_lb.application.dns_name
}

output "load_balancer_zone_id" {
  value = aws_lb.application.zone_id
}

output "load_balancer_security_group" {
  value = aws_lb.application.security_groups
}

# output "load_balancer_vpc_id" {
#   value = aws_lb.application.
# }