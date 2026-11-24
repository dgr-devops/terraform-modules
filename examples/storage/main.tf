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

module "datos" {
  source = "../../modules/storage"

  bucket_name = var.bucket_name
}
