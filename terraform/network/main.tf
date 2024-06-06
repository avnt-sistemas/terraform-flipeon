locals {
  azs = [for suffix in var.suffixes : "${var.region}${suffix}"]
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = var.vpc_name
    ProjectGroup = var.project_group
  }
}


resource "aws_eip" "nat" {
  count = length(module.vpc.azs)
  domain = "vpc"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
    ProjectGroup = var.project_group
  }
}

resource "aws_default_vpc" "this" {}
