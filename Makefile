ENV ?= dev
DIR := environments/$(ENV)

.PHONY: help init fmt fmt-check validate lint plan apply destroy output clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

init: ## terraform init for ENV
	terraform -chdir=$(DIR) init

fmt: ## Format all .tf files
	terraform fmt -recursive

fmt-check: ## Check formatting (CI)
	terraform fmt -check -recursive

validate: init ## Validate ENV
	terraform -chdir=$(DIR) validate

lint: ## Run tflint on all folders
	tflint --init --config "$(CURDIR)/.tflint.hcl"
	tflint --recursive --config "$(CURDIR)/.tflint.hcl"

plan: init ## Plan ENV and save to tfplan
	terraform -chdir=$(DIR) plan -out=tfplan

apply: ## Apply the saved plan for ENV
	terraform -chdir=$(DIR) apply tfplan

destroy: init ## Destroy ENV
	terraform -chdir=$(DIR) destroy

output: ## Show outputs for ENV
	terraform -chdir=$(DIR) output

clean: ## Remove local .terraform folders and plan files
	find . -type d -name ".terraform" -prune -exec rm -rf {} +
	find . -type f -name "tfplan" -delete
