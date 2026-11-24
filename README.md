# terraform-modules

[![CI](https://github.com/dgr-devops/terraform-modules/actions/workflows/ci.yml/badge.svg)](https://github.com/dgr-devops/terraform-modules/actions/workflows/ci.yml)

Tres módulos Terraform pequeños y reutilizables para AWS, seguros por defecto, con validaciones, tests offline y análisis estático (`tflint`, `trivy`).

| Módulo | Qué crea |
|---|---|
| [`modules/vpc`](modules/vpc) | VPC, subredes públicas y privadas, internet gateway, rutas, flow logs opcionales |
| [`modules/compute`](modules/compute) | Instancia EC2 + security group (IMDSv2, disco cifrado, sin reglas por defecto) |
| [`modules/storage`](modules/storage) | Bucket S3 cifrado, privado, versionado y solo TLS |

Cada módulo tiene `variables.tf`, `main.tf`, `outputs.tf`, `versions.tf`, su `README.md` y tests en `tests/`. Los ejemplos de uso están en [`examples/`](examples) (`vpc`, `compute`, `storage` y `complete`, que los encadena). Las decisiones de diseño y la justificación de los hallazgos de trivy están en [`docs/decisiones.md`](docs/decisiones.md).

## Uso

```hcl
module "datos" {
  source = "github.com/dgr-devops/terraform-modules//modules/storage?ref=main"

  bucket_name = "mi-empresa-datos-123456"
}
```

## Comprobaciones

Requisitos: `terraform >= 1.9` y Docker (para `tflint` y `trivy`, si no los tienes instalados). Nada necesita credenciales cloud.

```bash
make check     # fmt + validate + lint + security + test
make help      # lista de objetivos
```

### Salida real (Terraform v1.15.9, tflint 0.66.0, trivy 0.76.2)

`make test` — tests con `mock_provider`, solo `plan`, sin cuenta AWS:

```text
== modules/compute
  run "secure_defaults"... pass
  run "one_rule_per_cidr"... pass
  run "rejects_open_ssh"... pass
  run "rejects_bad_ami"... pass
tests/compute.tftest.hcl... pass
Success! 4 passed, 0 failed.
== modules/storage
  run "encrypted_with_sse_s3_by_default"... pass
  run "uses_kms_when_key_given"... pass
  run "no_lifecycle_without_versioning"... pass
  run "access_logging_optional"... pass
  run "rejects_bad_name"... pass
tests/storage.tftest.hcl... pass
Success! 5 passed, 0 failed.
== modules/vpc
  run "creates_subnets_and_routing"... pass
  run "no_public_ip_by_default"... pass
  run "no_igw_without_public_subnets"... pass
  run "flow_logs_only_when_destination_given"... pass
  run "flow_logs_enabled"... pass
  run "rejects_invalid_cidr"... pass
tests/vpc.tftest.hcl... pass
Success! 6 passed, 0 failed.
```

`make validate` (`init -backend=false` + `validate` en cada módulo y ejemplo):

```text
== modules/compute
Success! The configuration is valid.
== modules/storage
Success! The configuration is valid.
== modules/vpc
Success! The configuration is valid.
== examples/complete
Success! The configuration is valid.
== examples/compute
Success! The configuration is valid.
== examples/storage
Success! The configuration is valid.
== examples/vpc
Success! The configuration is valid.
```

`make lint` (tflint con el ruleset de AWS):

```text
lint exit=0
```

`make security` (`trivy config --exit-code 1`):

```text
Report Summary
┌─────────────────────────┬───────────┬───────────────────┐
│         Target          │   Type    │ Misconfigurations │
├─────────────────────────┼───────────┼───────────────────┤
│ examples/complete       │ terraform │         0         │
├─────────────────────────┼───────────┼───────────────────┤
│ examples/compute        │ terraform │         0         │
├─────────────────────────┼───────────┼───────────────────┤
│ examples/storage        │ terraform │         0         │
├─────────────────────────┼───────────┼───────────────────┤
│ examples/vpc            │ terraform │         0         │
├─────────────────────────┼───────────┼───────────────────┤
│ modules/storage/main.tf │ terraform │         0         │
├─────────────────────────┼───────────┼───────────────────┤
│ modules/vpc/main.tf     │ terraform │         0         │
└─────────────────────────┴───────────┴───────────────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)
```

## Qué está verificado y qué no

**Verificado** (comandos de arriba, ejecutados en local y en GitHub Actions, donde los tres jobs del CI pasan en verde):
- Formato (`terraform fmt -check`), `init -backend=false` y `validate` en 3 módulos y 4 ejemplos.
- 15 tests offline con proveedor simulado: valores por defecto seguros, conteos de recursos, validaciones que rechazan entradas peligrosas (SSH abierto al mundo, CIDR o AMI mal formados, nombre de bucket inválido).
- `tflint` sin hallazgos y `trivy config` sin hallazgos pendientes; los tres ignorados explícitamente están justificados en [`docs/decisiones.md`](docs/decisiones.md).
- El workflow de CI pasa `actionlint`.

**No verificado:**
- **Nunca se ha ejecutado `apply` ni `plan` contra una cuenta AWS real.** Los tests con proveedor simulado no detectan errores que solo devuelve la API (cuotas, nombre de bucket ya ocupado, AMI inexistente en la región).
- No se han probado versiones del proveedor AWS distintas de la 5.x.
- Los módulos no cubren NAT, balanceadores ni bases de datos (ver decisiones).

## Estructura

```text
modules/{vpc,compute,storage}/   variables.tf main.tf outputs.tf versions.tf tests/ README.md
examples/{vpc,compute,storage,complete}/
docs/decisiones.md
.github/workflows/ci.yml         fmt, validate, tests, tflint, trivy
Makefile  .tflint.hcl
```
