locals {
  common_tags = merge(var.tags, { ManagedBy = "terraform" })

  # Una regla de AWS por cada par (regla, CIDR): la API no admite varios CIDR por regla.
  ingress = {
    for pair in flatten([
      for r in var.ingress_rules : [
        for c in r.cidr_blocks : { key = "${r.protocol}-${r.port}-${c}", rule = r, cidr = c }
      ]
    ]) : pair.key => pair
  }
  egress = {
    for pair in flatten([
      for r in var.egress_rules : [
        for c in r.cidr_blocks : { key = "${r.protocol}-${r.port}-${c}", rule = r, cidr = c }
      ]
    ]) : pair.key => pair
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group de ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, { Name = "${var.name}-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress

  security_group_id = aws_security_group.this.id
  description       = each.value.rule.description
  ip_protocol       = each.value.rule.protocol
  from_port         = each.value.rule.port
  to_port           = each.value.rule.port
  cidr_ipv4         = each.value.cidr
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.egress

  security_group_id = aws_security_group.this.id
  description       = each.value.rule.description
  ip_protocol       = each.value.rule.protocol
  from_port         = each.value.rule.port
  to_port           = each.value.rule.port
  cidr_ipv4         = each.value.cidr
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = true

  # IMDSv2 obligatorio: mitiga el robo de credenciales vía SSRF.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size_gb
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  tags = merge(local.common_tags, { Name = var.name })
}
