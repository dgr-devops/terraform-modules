variable "name" {
  description = "Prefijo para el nombre de todos los recursos de red."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}$", var.name))
    error_message = "name debe tener 2-31 caracteres: minúsculas, números y guiones."
  }
}

variable "cidr_block" {
  description = "CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block no es un CIDR IPv4 válido."
  }
}

variable "availability_zones" {
  description = "Zonas de disponibilidad. La subred i-ésima usa la zona i-ésima."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 1
    error_message = "Hace falta al menos una zona de disponibilidad."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subredes públicas (con ruta a internet)."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for c in var.public_subnet_cidrs : can(cidrhost(c, 0))])
    error_message = "Todos los public_subnet_cidrs deben ser CIDRs IPv4 válidos."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subredes privadas (sin salida a internet; no se crea NAT)."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for c in var.private_subnet_cidrs : can(cidrhost(c, 0))])
    error_message = "Todos los private_subnet_cidrs deben ser CIDRs IPv4 válidos."
  }
}

variable "map_public_ip_on_launch" {
  description = "Asigna IP pública automática en las subredes públicas. Desactivado por defecto: asigna IPs de forma explícita."
  type        = bool
  default     = false
}

variable "flow_log_s3_bucket_arn" {
  description = "ARN de un bucket S3 donde enviar los VPC Flow Logs. Null desactiva los flow logs (el destino y su coste los decide quien llama al módulo)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Etiquetas adicionales para todos los recursos."
  type        = map(string)
  default     = {}
}
