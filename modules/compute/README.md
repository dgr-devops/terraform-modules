# Módulo `compute`

Instancia EC2 con su security group. IMDSv2 obligatorio, disco raíz gp3 cifrado, monitorización detallada.

```hcl
module "web" {
  source = "../../modules/compute"

  name      = "web"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  ami_id    = "ami-0123456789abcdef0"

  ingress_rules = [
    { description = "HTTPS interno", port = 443, cidr_blocks = ["10.0.0.0/16"] },
  ]
}
```

| Variable | Obligatoria | Descripción |
|---|---|---|
| `name`, `vpc_id`, `subnet_id`, `ami_id` | sí | Identificación y ubicación |
| `instance_type` | no (`t3.micro`) | Tipo de instancia |
| `root_volume_size_gb` | no (`8`) | 8–500 GiB |
| `kms_key_id` | no (`null`) | Clave KMS del disco (si no, la gestionada por AWS) |
| `associate_public_ip` | no (`false`) | IP pública |
| `ingress_rules` | no (`[]`) | Entrada; rechaza SSH a `0.0.0.0/0` |
| `egress_rules` | no (`[]`) | Salida; por defecto denegada |

Salidas: `instance_id`, `private_ip`, `security_group_id`.
