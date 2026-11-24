# Makefile — comprobaciones estáticas y tests offline de los módulos Terraform.
#
#   make fmt | validate | lint | security | test | check
#
# tflint y trivy se usan locales si están instalados; si no, sus imágenes Docker oficiales.
# Nada de esto necesita credenciales cloud ni crea recursos.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

MODULES  := $(sort $(wildcard modules/*))
EXAMPLES := $(sort $(wildcard examples/*))
ALL_DIRS := $(MODULES) $(EXAMPLES)

TFLINT_IMAGE ?= ghcr.io/terraform-linters/tflint:latest
TRIVY_IMAGE  ?= aquasec/trivy:latest
DOCKER_RUN   := docker run --rm -v "$(CURDIR):/data" -w /data

.DEFAULT_GOAL := help
.PHONY: help fmt validate lint security test check clean

help: ## Muestra esta ayuda
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

fmt: ## Comprueba el formato (terraform fmt -check)
	terraform fmt -check -recursive -diff

validate: ## terraform init -backend=false + validate en cada módulo y ejemplo
	@for d in $(ALL_DIRS); do \
	  echo "== $$d"; \
	  terraform -chdir="$$d" init -backend=false -input=false -no-color >/dev/null; \
	  terraform -chdir="$$d" validate -no-color; \
	done

lint: ## tflint (con el ruleset de AWS) sobre todo el repositorio
	@if command -v tflint >/dev/null; then \
	  tflint --init && tflint --recursive; \
	else \
	  $(DOCKER_RUN) --entrypoint sh $(TFLINT_IMAGE) -c 'tflint --init >/dev/null && tflint --recursive'; \
	fi

security: ## trivy config: falla ante cualquier hallazgo no justificado
	@if command -v trivy >/dev/null; then \
	  trivy config --exit-code 1 .; \
	else \
	  $(DOCKER_RUN) $(TRIVY_IMAGE) config --exit-code 1 .; \
	fi

test: ## terraform test con proveedor simulado (mock_provider), sin credenciales
	@for d in $(MODULES); do \
	  echo "== $$d"; \
	  terraform -chdir="$$d" init -backend=false -input=false -no-color >/dev/null; \
	  terraform -chdir="$$d" test -no-color; \
	done

check: fmt validate lint security test ## Todo lo anterior

clean: ## Borra los directorios .terraform y los locks generados
	find . -name .terraform -type d -prune -exec rm -r {} +
	find . -name .terraform.lock.hcl -delete
