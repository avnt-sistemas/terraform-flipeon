output "arn" {
  value = aws_acm_certificate.lb_cert.arn
}

output "validation_record_fqdns" {
  value = [for record in aws_route53_record.lb_cert_validation : record.fqdn]
}
