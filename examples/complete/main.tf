terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "Región de AWS."
  type        = string
  default     = "eu-west-1"
}


variable "bucket_name" {
  description = "Nombre global único del bucket."
  type        = string
}

variable "ami_id" {
  description = "AMI a usar (por ejemplo, una Amazon Linux 2023 de tu región)."
  type        = string
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = "completo"
  availability_zones   = ["${var.region}a", "${var.region}b"]
  public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
}

# La instancia va en una subred privada: no recibe IP pública.
module "app" {
  source = "../../modules/compute"

  name      = "completo-app"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  ami_id    = var.ami_id

  ingress_rules = [
    { description = "HTTP desde la VPC", port = 80, cidr_blocks = [module.vpc.vpc_cidr_block] },
  ]

  egress_rules = [
    { description = "HTTPS hacia la red interna (endpoints)", port = 443, cidr_blocks = [module.vpc.vpc_cidr_block] },
  ]
}

module "assets" {
  source = "../../modules/storage"

  bucket_name = var.bucket_name
}
