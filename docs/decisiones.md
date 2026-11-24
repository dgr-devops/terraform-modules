# Decisiones de diseño

## Alcance: tres módulos pequeños
`vpc`, `compute` y `storage` cubren lo que casi cualquier proyecto pequeño necesita (red, una máquina, un bucket). Se prefirió pocos módulos bien probados a un catálogo grande sin verificar.

## Seguro por defecto
Cada módulo parte de la opción segura y obliga a pedir expresamente lo contrario:

| Módulo | Por defecto | Cómo se relaja |
|---|---|---|
| `vpc` | Subredes públicas sin IP pública automática; security group por defecto sin reglas | `map_public_ip_on_launch = true` |
| `compute` | IMDSv2 obligatorio, disco raíz cifrado, sin reglas de entrada **ni de salida** | `ingress_rules`, `egress_rules` |
| `compute` | SSH abierto a `0.0.0.0/0` rechazado por validación | Indicar un CIDR concreto |
| `storage` | Acceso público bloqueado, solo TLS, versionado, `force_destroy = false` | Variables del módulo |

## Hallazgos de trivy: qué se corrigió y qué se justifica
- **AWS-0104** (salida a `0.0.0.0/0`, CRITICAL): **corregido**. Al principio el módulo traía una regla HTTPS de salida abierta; ahora no hay salida por defecto y los ejemplos usan el CIDR de la VPC.
- **AWS-0178** (VPC Flow Logs, MEDIUM): **mitigado y justificado**. El módulo crea el flow log si se le pasa `flow_log_s3_bucket_arn`. No se fuerza porque el destino y su coste los decide quien usa el módulo. Se ignora en el código con un comentario `trivy:ignore` que lo explica.
- **AWS-0089** (logs de acceso del bucket, LOW): **mitigado y justificado**, igual: `access_log_bucket` activa el registro; exige un bucket de destino distinto que el módulo no puede inventar.

Los ignores están en el código junto al recurso, no en un fichero global, para que se vean en la revisión.

## Sin NAT gateway
El módulo `vpc` no crea NAT: cuesta dinero por hora aunque no se use, y no es necesario para el ejemplo. Las subredes privadas no tienen salida a internet. Si hace falta, se añade fuera del módulo o en una versión futura.

## AMI explícita
`compute` recibe `ami_id` en vez de buscarla con un `data source`. Así `plan` y los tests no dependen de credenciales ni de la API de AWS, y la elección de imagen queda a la vista de quien lo usa.

## Reglas de security group con recursos propios
Se usan `aws_vpc_security_group_ingress_rule` / `egress_rule` (una por regla y CIDR) en lugar de bloques `ingress {}` embebidos: es el enfoque recomendado por el proveedor y evita conflictos al cambiar reglas. Por eso `cidr_blocks` se expande a una regla de AWS por cada CIDR.

## Tests offline con `mock_provider`
`terraform test` con `command = plan` y `mock_provider "aws" {}` comprueba la lógica (conteos, validaciones, valores por defecto) sin credenciales ni recursos reales. Límite conocido: un proveedor simulado **no** detecta errores que solo devuelve la API real (cuotas, nombres de bucket ya usados, AMI inexistente).

## Versiones
Terraform `>= 1.9` (validaciones que referencian otras variables y `mock_provider`), proveedor AWS `~> 5.0`. Los ficheros `.terraform.lock.hcl` no se versionan: son bibliotecas de módulos y cada proyecto que las use fija el suyo.

## Qué no se ha hecho
Nunca se ha ejecutado `apply` ni `plan` contra una cuenta real. Ver el README, sección «Qué está verificado y qué no».
