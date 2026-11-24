output "bucket_arn" {
  description = "ARN del bucket de ejemplo."
  value       = module.datos.bucket_arn
}

output "encryption_algorithm" {
  description = "Cifrado aplicado."
  value       = module.datos.encryption_algorithm
}
