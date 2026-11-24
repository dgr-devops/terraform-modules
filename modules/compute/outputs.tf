output "instance_id" {
  description = "ID de la instancia."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "IP privada de la instancia."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "ID del security group de la instancia."
  value       = aws_security_group.this.id
}
