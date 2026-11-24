# Módulo `vpc`

VPC con subredes públicas (ruta a un internet gateway) y privadas (sin salida), y el security group por defecto sin reglas.

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name                 = "ejemplo"
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}
```

| Variable | Obligatoria | Descripción |
|---|---|---|
| `name` | sí | Prefijo de nombres |
| `availability_zones` | sí | Zonas; la subred *i* usa la zona *i* (cíclico) |
| `cidr_block` | no (`10.0.0.0/16`) | CIDR de la VPC |
| `public_subnet_cidrs` / `private_subnet_cidrs` | no (`[]`) | CIDRs de subredes |
| `map_public_ip_on_launch` | no (`false`) | IP pública automática en subredes públicas |
| `flow_log_s3_bucket_arn` | no (`null`) | Destino S3 de los flow logs |
| `tags` | no | Etiquetas extra |

Salidas: `vpc_id`, `vpc_cidr_block`, `public_subnet_ids`, `private_subnet_ids`, `internet_gateway_id`.
