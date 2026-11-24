output "vpc_id" {
  description = "ID de la VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR de la VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas, en el orden de public_subnet_cidrs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas, en el orden de private_subnet_cidrs."
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID del internet gateway (null si no hay subredes públicas)."
  value       = one(aws_internet_gateway.this[*].id)
}
