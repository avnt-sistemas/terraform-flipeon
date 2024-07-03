provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "network" {
  source        = "./network"
  region        = var.region
  project_group = var.project_group
  vpc_name = var.project_name
}

module "rds_security_group" {
  source    = "./sg"
  vpc_id    = module.network.vpc_id
}

module "load_balancer" {
  source                 = "./lb"
  vpc_id                 = module.network.vpc_id
  security_group_id      = module.rds_security_group.rds_security_group_id
  subnet_ids             = module.network.private_subnets
  
  region                 = var.region
  project_group          = var.project_group
  environment            = var.environment
  project_name           = var.project_name
}

module "route53" {
  source = "./r53"
  environment = var.environment

  lb_dns_name = module.load_balancer.load_balancer_dns_name
  lb_zone_id  = module.load_balancer.load_balancer_zone_id
}

module "ecs_app" {
  source = "./ecs"
  cluster_name = "${var.project_name}-app-${var.environment}"

  region = var.region

  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.private_subnets
  source_security_group_ids = [module.network.security_group_id]
  lb_target_group = module.load_balancer.load_balancer_target_group

  desired_capacity = 1
  max_capacity = 2
  task_cpu         = 256
  task_memory      = 512
  
}

module "ecs_api" {
  source = "./ecs"
  cluster_name = "${var.project_name}-api-${var.environment}"

  region = var.region

  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.private_subnets
  source_security_group_ids = [module.network.security_group_id]
  lb_target_group = module.load_balancer.load_balancer_target_group

  desired_capacity = 1
  max_capacity = 2
  task_cpu         = 256
  task_memory      = 512
}


module "rds" {
  source          = "./rds"
  db_identifier = "flipeon-rds-${var.environment}"
  db_name = "flipeon_${var.environment}"
  db_username = var.project_name
  
  vpc_id = module.network.vpc_id
  database_subnet_group   = module.network.database_subnet_group

  db_family = "postgres14"
  db_engine_version = "14"

  depends_on = [ module.network ]
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

module "cloudfront_bucket" {
  source = "./s3"
  bucket_name = "cloudfront-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group

  transition_days = 3
}

module "cloudfront" {
  source                = "./cloudfront"
  project_name          = var.project_name
  environment           = var.environment 
  origin_domain_name    = module.cloudfront_bucket.bucket_domain_name
  default_root_object   = "index.html"
  project_group         = var.project_group
}

module "cloudwatch" {
  source                = "./cloudwatch"
  log_group_name        = "${var.project_name}-logs-${var.environment}"
}