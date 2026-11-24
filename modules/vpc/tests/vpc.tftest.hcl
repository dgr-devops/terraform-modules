mock_provider "aws" {}

variables {
  name                 = "demo"
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24"]
}

run "creates_subnets_and_routing" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 1
    error_message = "Se esperaban 2 subredes públicas y 1 privada."
  }

  assert {
    condition     = length(aws_internet_gateway.this) == 1
    error_message = "Con subredes públicas debe existir un internet gateway."
  }

  assert {
    condition     = aws_subnet.public[1].availability_zone == "eu-west-1b"
    error_message = "La segunda subred pública debe ir a la segunda zona."
  }
}

run "no_public_ip_by_default" {
  command = plan

  assert {
    condition     = aws_subnet.public[0].map_public_ip_on_launch == false
    error_message = "Las subredes públicas no deben asignar IP pública por defecto."
  }
}

run "no_igw_without_public_subnets" {
  command = plan

  variables {
    public_subnet_cidrs = []
  }

  assert {
    condition     = length(aws_internet_gateway.this) == 0
    error_message = "Sin subredes públicas no debe crearse internet gateway."
  }
}

run "flow_logs_only_when_destination_given" {
  command = plan

  assert {
    condition     = length(aws_flow_log.this) == 0
    error_message = "Sin destino no deben crearse flow logs."
  }
}

run "flow_logs_enabled" {
  command = plan

  variables {
    flow_log_s3_bucket_arn = "arn:aws:s3:::logs-demo"
  }

  assert {
    condition     = length(aws_flow_log.this) == 1
    error_message = "Con destino debe crearse un flow log."
  }
}

run "rejects_invalid_cidr" {
  command = plan

  variables {
    cidr_block = "no-es-un-cidr"
  }

  expect_failures = [var.cidr_block]
}
