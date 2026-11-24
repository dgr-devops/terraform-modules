output "vpc_id" {
  description = "ID de la VPC de ejemplo."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas."
  value       = module.vpc.public_subnet_ids
}
