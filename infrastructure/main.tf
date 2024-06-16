terraform {
  backend "local" {
    path = "local.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region     = local.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.0"

  name = "${local.common_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.0.0/18", "10.0.64.0/18"]
  public_subnets  = ["10.0.128.0/18", "10.0.192.0/18"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  map_public_ip_on_launch = true

  tags = {
    Fastcampus = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.common_prefix}-cluster"
  cluster_version = local.eks_cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  eks_managed_node_groups = {
    primary = {
      min_size       = local.eks_ng_min_size
      max_size       = local.eks_ng_max_size
      desired_size   = local.eks_ng_desired_size
      instance_types = [local.eks_instance_type]
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Fastcampus = "true"
  }
}

resource "aws_db_instance" "rds" {
  identifier = "${local.common_prefix}-db"

  engine         = "postgres"
  engine_version = local.rds_engine_version
  instance_class = local.rds_instance_class

  storage_type      = "gp3"
  allocated_storage = local.rds_allocated_storage

  db_name  = local.rds_db_name
  username = local.common_prefix
  password = var.rds_password
  port     = "5432"

  iam_database_authentication_enabled = true
  skip_final_snapshot                 = true
  deletion_protection                 = false
  publicly_accessible                 = false
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.common_prefix}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name       = "${local.common_prefix}-db-subnet-group"
    Fastcampus = "true"
  }
}

resource "aws_security_group" "rds_security_group" {
  name   = "${local.common_prefix}-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  tags = {
    Name       = "${local.common_prefix}-security-group"
    Fastcampus = "true"
  }
}

resource "aws_ecr_repository" "application_images" {
  name = "${local.common_prefix}-image"

  tags = {
    Name       = "${local.common_prefix}-image"
    Fastcampus = "true"
  }
}