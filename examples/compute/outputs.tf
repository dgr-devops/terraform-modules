output "instance_id" {
  description = "ID de la instancia de ejemplo."
  value       = module.web.instance_id
}

output "security_group_id" {
  description = "ID del security group."
  value       = module.web.security_group_id
}
