output "vpc_id" {
  description = "ID de la VPC."
  value       = module.vpc.vpc_id
}

output "instance_id" {
  description = "ID de la instancia."
  value       = module.app.instance_id
}

output "bucket_arn" {
  description = "ARN del bucket."
  value       = module.assets.bucket_arn
}
