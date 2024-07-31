# Definições locais para o ambiente e configurações relacionadas
locals {
  # Define o domínio, incluindo o ambiente se não for produção
  domain = var.environment != "prod" ? "${var.environment}.${var.domain_name}" : var.domain_name

  # Define a versão da imagem do ECR com base no ambiente
  ecr_image_version = var.environment == "dev" ? "pre-release" : var.environment == "prod" ? "latest" : "${var.environment}-release"

  # Define a string de conexão com o banco de dados
  connection_string = "Server=${module.rds.db_endpoint};Database=flipeon_${var.environment};Port=${module.rds.db_port};User Id=${var.project_name};Password=${module.rds.db_password}"
}

# Provedor AWS
provider "aws" {
  # Região onde os recursos serão criados
  region = var.region
}

# Dados do usuário atual da AWS
data "aws_caller_identity" "current" {}

# Módulo para configurar a rede (VPC, subnets, etc.)
module "network" {
  source        = "./network"
  region        = var.region
  environment   = var.environment
  project_group = var.project_group
  vpc_name      = var.project_name
  project_name  = var.project_name
}

# Módulo para configurar grupos de segurança
module "security_groups" {
  source = "./sg"
  project_group         = var.project_group
  vpc_id                 = module.network.vpc_id
}

# Cria uma zona do Route 53 para o domínio
resource "aws_route53_zone" "primary" {
  # Nome da zona DNS
  name = local.domain
}

# Módulo para configurar o bucket de logs
module "logs_bucket" {
  source = "./s3"
  bucket_name = "logs-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group
  transition_days = 3
  expiration_days = 365
}

# Módulo para configurar o balanceador de carga
module "load_balancer" {
  source                = "./lb"
  region                = var.region
  project_name          = var.project_name
  project_group         = var.project_group
  domain_name           = local.domain
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  security_group_id     = module.security_groups.ecs_security_group_id
  subnet_ids            = module.network.public_subnets
  certificate_arn       = "" # O ARN do certificado pode ser adicionado aqui quando disponível
  logs_bucket           = module.logs_bucket.bucket_domain_name
}

# Módulo para configurar registros DNS do Route 53
module "route53" {
  source      = "./r53"
  environment = var.environment
  lb_dns_name = module.load_balancer.load_balancer_dns_name
  lb_zone_id  = module.load_balancer.load_balancer_zone_id
  region      = var.region
  dns_zone    = aws_route53_zone.primary.zone_id
}

# Módulo para configurar o banco de dados RDS
module "rds" {
  source                  = "./rds"
  environment             = var.environment
  db_identifier           = "flipeon-rds-${var.environment}"
  db_name                 = "flipeon_${var.environment}"
  db_username             = var.project_name
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.public_subnets
  database_subnet_group   = module.network.database_subnet_group
  vpc_security_group_ids  = [module.security_groups.rds_security_group_id]
  project_group           = var.project_group
  load_balancer_security_group = module.load_balancer.load_balancer_security_group
}

# Registra o endpoint do RDS no Route 53, exceto em produção
resource "aws_route53_record" "r53_rds_endpoint" {
  count = var.environment == "prod" ? 0 : 1 # Em produção não precisamos de acesso externo ao banco de dados
  zone_id = aws_route53_zone.primary.zone_id
  name    = "db.${local.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [module.rds.db_endpoint]
}

# Módulo para configurar a fila SQS de upload
module "upload_sqs" {
  source = "./sqs"
  queue_name = "nfce-s3-storage-queue"
}

# Repositório ECR para a aplicação
resource "aws_ecr_repository" "ecr_app" {
  name                 = "flipeon-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name         = "flipeon-app-ecr"
    ProjectGroup = var.project_group
  }
}

# Repositório ECR para a API
resource "aws_ecr_repository" "ecr_api" {
  name                 = "flipeon-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name         = "flipeon-api-ecr"
    ProjectGroup = var.project_group
  }
}

# Módulo para configurar os serviços ECS da aplicação
module "ecs_app" {
  source = "./ecs"
  cluster_name = "${var.project_name}-app-${var.environment}"
  image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/flipeon-app:${local.ecr_image_version}"
  region = var.region
  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.public_subnets
  source_security_group_ids = [module.security_groups.ecs_security_group_id]
  lb_target_group = module.load_balancer.target_group_app_arn
  desired_capacity = 1
  max_capacity     = 2
  task_cpu         = 256
  task_memory      = 512
  environment_vars = [
    {
      name = "API_URL"
      value = "${var.environment == "prod" ? "https://" : "http://" }api.${local.domain}"
    },
  ]
  depends_on = [ module.load_balancer ]
}

# Módulo para configurar os serviços ECS da API
module "ecs_api" {
  source = "./ecs"
  cluster_name = "${var.project_name}-api-${var.environment}"
  image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/flipeon-api:${local.ecr_image_version}"
  region = var.region
  vpc_id     = module.network.vpc_id  
  subnet_ids = module.network.public_subnets
  source_security_group_ids = [module.security_groups.ecs_security_group_id]
  lb_target_group = module.load_balancer.target_group_api_arn
  desired_capacity = 1
  max_capacity = 2
  task_cpu         = 256
  task_memory      = 512
  environment_vars = [
    {
      name  = "EpConnectionString"
      value = local.connection_string
    },
    {
      name  = "ibpt-token"
      value = "NxYOJ2dz09WvMrBPoLglwUScLUQWQ3OL"
    },
    {
      name  = "download-lambda-name"
      value = "nfce-download-lambda"
    },
    {
      name  = "PORT"
      value = "80"
    },
    {
      name  = "email-port"
      value = "587"
    },
    {
      name  = "ASPNETCORE_URLS"
      value = "http://0.0.0.0:80"
    },
    {
      name  = "email-host"
      value = "email-smtp.sa-east-1.amazonaws.com"
    },
    {
      name  = "email-account"
      value = "nao-responder@flipeon.com"
    },
    {
      name  = "NFCE_SQS_URL"
      value = module.upload_sqs.sqs_queue_id # O ID da queue é literalmente a url de acesso da mesma
    },
    {
      name  = "aws-region"
      value = var.region
    },
    {
      name  = "nfce-sqs-name"
      value = "nfce-s3-storage-queue"
    },
  ]
  depends_on = [ module.load_balancer ]
}

# Módulo para configurar o bucket de documentos
module "docs_bucket" {
  source = "./s3"
  bucket_name = "docs-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group
  expiration_days = null
  transition_days = null
}

# Módulo para configurar o bucket de uploads
module "uploads_bucket" { 
  source = "./s3"
  bucket_name = "uploads-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group
}

# Módulo para configurar o bucket de suporte
module "support_bucket" {
  source = "./s3"
  bucket_name = "support-bucket-${var.project_name}-${var.environment}"
  project_group = var.project_group
  expiration_days = 30
  transition_days = 7
}

# Módulo para configurar o CloudWatch
module "cloudwatch" {
  source                = "./cloudwatch"
  project_group         = var.project_group
  load_balancer_name    = module.load_balancer.load_balancer_name
  log_group_name        = "${var.project_name}-logs"
  retention_in_days     = 7
  environment           = var.environment
}
