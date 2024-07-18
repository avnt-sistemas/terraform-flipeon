provider "aws" {
  region = var.region
}

locals {
  suffix = "${var.project_name}-${var.environment}"
}

resource "null_resource" "create_cert" {
  # Executar o script apenas quando os arquivos não existirem
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "${path.module}/${var.domain_name}.key" ] || [ ! -f "${path.module}/${var.domain_name}.csr" ]; then
        ./create-cert.sh ${var.domain_name} ${path.module}
      else
        echo "Arquivos de certificado já existem."
      fi
    EOT
    
    # Executar na pasta onde está o script
    working_dir = path.module
  }
}

resource "aws_acm_certificate" "lb_cert" {
  # domain_name       = var.domain_name
  private_key       = filebase64("${path.module}/${var.domain_name}.key")
  certificate_body  = filebase64("${path.module}/${var.domain_name}.csr")

  tags = {
    Name         = "cert-${local.suffix}"
    ProjectGroup = var.project_group
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [null_resource.create_cert]
}

# resource "aws_route53_record" "lb_cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.lb_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }

#   zone_id         = var.dns_zone
#   name            = each.value.name
#   type            = each.value.type
#   ttl             = 60
#   records         = [each.value.record]
#   allow_overwrite = true

# }

# resource "aws_acm_certificate_validation" "lb_cert" {
#   certificate_arn         = aws_acm_certificate.lb_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.lb_cert_validation : record.fqdn]
# }

# resource "tls_private_key" "ca_private_key" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }

# resource "tls_self_signed_cert" "ca_cert" {
#   depends_on = [tls_private_key.ca_private_key]
#   private_key_pem = tls_private_key.ca_private_key.private_key_pem

#   dns_names = [
#     "*.${var.domain_name}",
#     "*.app.${var.domain_name}",
#     "*.api.${var.domain_name}"
#   ]

#   subject {
#     common_name = "${var.project_name}-rsa-key"
#     organization = var.project_name
#   }

#   validity_period_hours = 24

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#   ]
# }

# resource "aws_acm_certificate" "lb_cert" {
  
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "www.${var.domain_name}",
#     "*.app.${var.domain_name}",
#     "*.api.${var.domain_name}"
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   options {
#     certificate_transparency_logging_preference = "ENABLED"
#   }

#   tags = {
#     Name         = "crt-${local.suffix}"
#     ProjectGroup = var.project_group
#   }
# }

# resource "aws_route53_record" "lb_cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.lb_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }

#   zone_id = var.dns_zone
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.record]

#   allow_overwrite = true
# }

# resource "aws_acm_certificate_validation" "lb_cert" {
#   certificate_arn         = aws_acm_certificate.lb_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.lb_cert_validation : record.fqdn]
# }