output "bucket_id" {
  description = "Nombre del bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN del bucket."
  value       = aws_s3_bucket.this.arn
}

output "encryption_algorithm" {
  description = "Algoritmo de cifrado en reposo aplicado."
  value       = local.sse_algo
}
