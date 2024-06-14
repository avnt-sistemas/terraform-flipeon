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

module "eks" {

  count = var.use_eks ? 1 : 0

  source = "./eks"
  key_name         = "${var.project_name}-${var.environment}"
  cluster_name     = "${var.project_name}-${var.environment}"

  vpc_id                   = module.network.vpc_id  
  subnet_ids               = module.network.private_subnets
  control_plane_subnet_ids = module.network.private_subnets
  source_security_group_ids = [module.network.security_group_id]
}

module "ecs" {
  count = var.use_eks ? 0 : 1

  source = "./ecs"
  cluster_name = "${var.project_name}-${var.environment}"

  region = var.region
  account_id = "457504760127"


  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.private_subnets
  source_security_group_ids = [module.network.security_group_id]

  desired_capacity = 1
  max_capacity = 2
  task_cpu         = 1024
  task_memory      = 4096
}

module "rds" {
  source          = "./rds"
  db_identifier = "flipeon-rds-${var.environment}"
  db_name = "flipeon-rds-${var.environment}"
  db_username = var.project_name
  
  default_security_group_id = module.network.security_group_id
  database_subnet_group   = module.network.database_subnet_group
}

module "rds_security_group" {
  source    = "./sg"
  vpc_id    = module.network.vpc_id
}

module "load_balancer" {
  source                 = "./lb"
  vpc_id                 = module.network.vpc_id
  security_group_id      = module.rds_security_group.rds_security_group_id
  ssl_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef01-1234-5678-90ab-cdef01234567"
  subnet_ids             = module.network.subnet_ids
  
  project_group          = var.project_group
  environment            = var.environment
  project_name           = var.project_name
}

module "cloudfront" {
  source                = "./cloudfront"
  origin_domain_name    = "${var.project_name}.jnmoura.com.br"
  default_root_object   = "index.html"
  project_group         = var.project_group
}

module "cloudwatch" {
  source                = "./cloudwatch"
  log_group_name        = "${var.project_name}-logs-${var.environment}"
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

module "route53" {
  source = "./route53"
}