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


variable "vpc_id" {
  description = "VPC existente donde crear el security group."
  type        = string
}

variable "subnet_id" {
  description = "Subred existente donde lanzar la instancia."
  type        = string
}

variable "ami_id" {
  description = "AMI a usar (por ejemplo, una Amazon Linux 2023 de tu región)."
  type        = string
}

module "web" {
  source = "../../modules/compute"

  name      = "ejemplo-web"
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
  ami_id    = var.ami_id

  ingress_rules = [
    { description = "HTTPS desde la red interna", port = 443, cidr_blocks = ["10.0.0.0/16"] },
    { description = "SSH desde la oficina (CIDR de documentación)", port = 22, cidr_blocks = ["203.0.113.0/24"] },
  ]

  egress_rules = [
    { description = "HTTPS hacia la red interna (endpoints)", port = 443, cidr_blocks = ["10.0.0.0/16"] },
  ]
}
