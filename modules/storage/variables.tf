variable "bucket_name" {
  description = "Nombre global único del bucket S3."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name debe tener 3-63 caracteres: minúsculas, números, puntos y guiones."
  }
}

variable "kms_key_arn" {
  description = "ARN de una clave KMS propia para cifrar. Null usa SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "versioning_enabled" {
  description = "Activa el versionado de objetos."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Días tras los que se borran versiones antiguas. 0 desactiva la regla (solo aplica con versionado)."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 0
    error_message = "noncurrent_version_expiration_days no puede ser negativo."
  }
}

variable "access_log_bucket" {
  description = "Bucket de destino para los logs de acceso. Null desactiva el registro de accesos."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Permite borrar el bucket aunque tenga objetos. Falso por defecto para evitar pérdidas de datos."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Etiquetas adicionales para todos los recursos."
  type        = map(string)
  default     = {}
}
