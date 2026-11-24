mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  bucket_name = "demo-datos-123456"
}

run "encrypted_with_sse_s3_by_default" {
  command = plan

  assert {
    condition     = output.encryption_algorithm == "AES256"
    error_message = "Por defecto debe usarse AES256."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls && aws_s3_bucket_public_access_block.this.restrict_public_buckets
    error_message = "El acceso público debe estar bloqueado."
  }

  assert {
    condition     = aws_s3_bucket.this.force_destroy == false
    error_message = "force_destroy debe ser falso por defecto."
  }
}

run "uses_kms_when_key_given" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:eu-west-1:000000000000:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = output.encryption_algorithm == "aws:kms"
    error_message = "Con kms_key_arn debe usarse aws:kms."
  }
}

run "no_lifecycle_without_versioning" {
  command = plan

  variables {
    versioning_enabled = false
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "Sin versionado no debe haber regla de ciclo de vida."
  }
}

run "access_logging_optional" {
  command = plan

  variables {
    access_log_bucket = "logs-demo"
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) == 1
    error_message = "Con access_log_bucket debe activarse el registro de accesos."
  }
}

run "rejects_bad_name" {
  command = plan

  variables {
    bucket_name = "Nombre_Inválido"
  }

  expect_failures = [var.bucket_name]
}
