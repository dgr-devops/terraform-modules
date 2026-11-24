mock_provider "aws" {}

variables {
  name      = "web"
  vpc_id    = "vpc-0123456789abcdef0"
  subnet_id = "subnet-0123456789abcdef0"
  ami_id    = "ami-0123456789abcdef0"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = aws_instance.this.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 debe ser obligatorio."
  }

  assert {
    condition     = aws_instance.this.root_block_device[0].encrypted == true
    error_message = "El volumen raíz debe ir cifrado."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 0
    error_message = "Por defecto no debe haber reglas de entrada."
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.this) == 0
    error_message = "Por defecto no debe haber reglas de salida."
  }
}

run "one_rule_per_cidr" {
  command = plan

  variables {
    ingress_rules = [
      { description = "HTTP", port = 80, cidr_blocks = ["10.0.0.0/16", "192.168.0.0/24"] },
    ]
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 2
    error_message = "Debe crearse una regla de AWS por cada CIDR."
  }
}

run "rejects_open_ssh" {
  command = plan

  variables {
    ingress_rules = [
      { description = "SSH", port = 22, cidr_blocks = ["0.0.0.0/0"] },
    ]
  }

  expect_failures = [var.ingress_rules]
}

run "rejects_bad_ami" {
  command = plan

  variables {
    ami_id = "centos"
  }

  expect_failures = [var.ami_id]
}
