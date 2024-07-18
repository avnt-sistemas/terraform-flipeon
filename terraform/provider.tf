locals {
  domain = var.environment != "prod" ? "${var.environment}.${var.domain_name}" : var.domain_name
}

provider "aws" {
  region = var.region
}

module "network" {
  source        = "./network"
  region        = var.region
  environment   = var.environment
  project_group = var.project_group
  vpc_name      = var.project_name
  project_name  = var.project_name
}

module "gateway" {
  source = "./gw"
  project_group = var.project_group
  project_name = var.project_name
  vpc_id = module.network.vpc_id

  public_subnets = module.network.public_subnet
}

module "security_groups" {
  source = "./sg"

  # project_name          = var.project_name
  project_group         = var.project_group
  
  vpc_id = module.network.vpc_id
}


# I need make a hosted zone before certificate, but dns records after all script run
resource "aws_route53_zone" "primary" {
  name = local.domain
}

module "logs_bucket" {
  source = "./s3"
  bucket_name = "logs-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group

  transition_days = 3
  expiration_days = 365
}


# module "certificate" {
#   source = "./acm"

#   region        = var.region
#   project_name  = var.project_name
#   project_group = var.project_group
#   environment   = var.environment
#   domain_name   = local.domain

#   dns_zone = aws_route53_zone.primary.zone_id
# }

module "load_balancer" {
  source                = "./lb"
  region                = var.region
  project_name          = var.project_name
  project_group         = var.project_group
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  security_group_id     = module.security_groups.ecs_security_group_id
  subnet_ids            = module.network.private_subnets

  certificate_arn       = "" # module.certificate.arn

  logs_bucket = module.logs_bucket.bucket_domain_name
}

module "route53" {
  source      = "./r53"
  environment = var.environment
  lb_dns_name = module.load_balancer.load_balancer_dns_name
  lb_zone_id  = module.load_balancer.load_balancer_zone_id
  region      = var.region
  dns_zone    = aws_route53_zone.primary.zone_id
}

module "rds" {
  source          = "./rds"
  db_identifier = "flipeon-rds-${var.environment}"
  db_name = "flipeon_${var.environment}"
  db_username = var.project_name

  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.private_subnets
  database_subnet_group   = module.network.database_subnet_group
  vpc_security_group_ids  = [module.security_groups.rds_security_group_id]

  project_group = var.project_group

  load_balancer_security_group = module.load_balancer.load_balancer_security_group
}

module "ecs_app" {
  source = "./ecs"
  cluster_name = "${var.project_name}-app-${var.environment}"

  region = var.region

  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.private_subnets
  source_security_group_ids = [module.security_groups.ecs_security_group_id]
  lb_target_group = module.load_balancer.target_group_arn

  desired_capacity = 1
  max_capacity     = 2
  task_cpu         = 256
  task_memory      = 512

  depends_on = [ module.load_balancer ]

}

module "ecs_api" {
  source = "./ecs"
  cluster_name = "${var.project_name}-api-${var.environment}"

  region = var.region

  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.private_subnets
  source_security_group_ids = [module.security_groups.ecs_security_group_id]
  lb_target_group = module.load_balancer.target_group_arn

  desired_capacity = 1
  max_capacity = 2
  task_cpu         = 256
  task_memory      = 512

  depends_on = [ module.load_balancer ]
}



module "docs_bucket" {
  source = "./s3"
  bucket_name = "docs-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group

  expiration_days = null
  transition_days = null
}

module "uploads_bucket" { 
  source = "./s3"
  bucket_name = "uploads-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group
}

module "support_bucket" {
  source = "./s3"
  bucket_name = "support-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group

  expiration_days = 30
  transition_days = 7
}


# module "cloudfront" {
#   source                = "./cloudfront"
#   project_name          = var.project_name
#   environment           = var.environment 
#   origin_domain_name    = module.logs_bucket.bucket_domain_name
#   default_root_object   = "index.html"
#   project_group         = var.project_group
#   certificate_arn       = "" # module.certificate.arn
#   region                = var.region 
# }

module "cloudwatch" {
  source                = "./cloudwatch"
  log_group_name        = "${var.project_name}-logs-${var.environment}"
}