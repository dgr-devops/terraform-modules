# Módulo `storage`

Bucket S3 cifrado: acceso público bloqueado, propietario forzado, versionado, ciclo de vida de versiones antiguas y política que exige TLS.

```hcl
module "datos" {
  source = "../../modules/storage"

  bucket_name = "mi-empresa-datos-123456"
}
```

| Variable | Obligatoria | Descripción |
|---|---|---|
| `bucket_name` | sí | Nombre global único |
| `kms_key_arn` | no (`null`) | Clave KMS propia; si no, SSE-S3 (AES256) |
| `versioning_enabled` | no (`true`) | Versionado |
| `noncurrent_version_expiration_days` | no (`90`) | Caducidad de versiones antiguas (0 = sin regla) |
| `access_log_bucket` | no (`null`) | Bucket de destino para logs de acceso |
| `force_destroy` | no (`false`) | Permite borrar con objetos dentro |
| `tags` | no | Etiquetas extra |

Salidas: `bucket_id`, `bucket_arn`, `encryption_algorithm`.
