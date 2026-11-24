variable "name" {
  description = "Nombre de la instancia y de su security group."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}$", var.name))
    error_message = "name debe tener 2-31 caracteres: minúsculas, números y guiones."
  }
}

variable "vpc_id" {
  description = "ID de la VPC donde se crea el security group."
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se lanza la instancia."
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI. Se pasa explícito para que el módulo no dependa de data sources ni de credenciales al planificar."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "ami_id debe tener el formato ami-xxxxxxxx."
  }
}

variable "instance_type" {
  description = "Tipo de instancia."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "Tamaño del volumen raíz en GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size_gb >= 8 && var.root_volume_size_gb <= 500
    error_message = "root_volume_size_gb debe estar entre 8 y 500."
  }
}

variable "kms_key_id" {
  description = "ARN de una clave KMS para cifrar el volumen raíz. Null usa la clave gestionada por AWS (el volumen siempre va cifrado)."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Asigna IP pública a la instancia."
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "Reglas de entrada del security group. Por defecto no se permite ninguna."
  type = list(object({
    description = string
    port        = number
    protocol    = optional(string, "tcp")
    cidr_blocks = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.ingress_rules : alltrue([for c in r.cidr_blocks : can(cidrhost(c, 0))])
    ])
    error_message = "Todos los cidr_blocks de ingress_rules deben ser CIDRs IPv4 válidos."
  }

  validation {
    condition = alltrue([
      for r in var.ingress_rules : !(r.port == 22 && contains(r.cidr_blocks, "0.0.0.0/0"))
    ])
    error_message = "No se permite SSH (22) abierto a 0.0.0.0/0; indica un CIDR concreto."
  }
}

variable "egress_rules" {
  description = "Reglas de salida. Por defecto no se permite ninguna (denegar todo); declara solo lo necesario y evita 0.0.0.0/0."
  type = list(object({
    description = string
    port        = number
    protocol    = optional(string, "tcp")
    cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Etiquetas adicionales para todos los recursos."
  type        = map(string)
  default     = {}
}
