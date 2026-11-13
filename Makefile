# Account vending (Layer 0) — offline verification harness.
# Every check here runs with no live AWS account.

SHELL := /bin/bash
export TF_PLUGIN_CACHE_DIR ?= $(HOME)/.terraform.d/plugin-cache

# Terraform roots verified in the routine loop (any dir with *.tf), excluding
# provider caches and the AFT bootstrap (a large remote module — see verify-aft).
TF_DIRS := $(shell find . -name '*.tf' -not -path '*/.terraform/*' -not -path '*/aft-bootstrap/*' -exec dirname {} \; 2>/dev/null | sort -u)
# All CloudFormation templates under account customizations.
CFN_TEMPLATES := $(shell find aft -name 'template.yaml' 2>/dev/null)

.PHONY: verify verify-tf verify-cfn verify-py verify-actions tools init

verify: verify-tf verify-cfn verify-py verify-actions ## run every offline check

tools: ## confirm the toolchain is present
	@for t in terraform tflint checkov cfn-lint cfn-guard actionlint python3; do \
	  command -v $$t >/dev/null && printf 'ok   %s\n' "$$t" || { printf 'MISSING %s\n' "$$t"; exit 1; }; \
	done

init: ## one-time: prime the tflint plugin cache
	@mkdir -p "$(TF_PLUGIN_CACHE_DIR)"
	@tflint --init

verify-tf: ## terraform fmt/validate + test + tflint + checkov for every root
	@mkdir -p "$(TF_PLUGIN_CACHE_DIR)"
	@test -n "$(TF_DIRS)" || { echo "no terraform roots yet"; exit 0; }
	@for d in $(TF_DIRS); do \
	  echo "== terraform: $$d =="; \
	  ( cd $$d && terraform fmt -check && terraform init -backend=false >/dev/null && \
	    terraform validate && terraform test && tflint && \
	    checkov -d . --quiet --compact --framework terraform ) || exit 1; \
	done

verify-cfn: ## cfn-lint + cfn-guard for every baseline template
	@test -n "$(CFN_TEMPLATES)" || { echo "no cloudformation templates yet"; exit 0; }
	@for t in $(CFN_TEMPLATES); do \
	  echo "== cfn: $$t =="; \
	  cfn-lint "$$t" || exit 1; \
	  r="$$(dirname $$t)/rules/baseline.guard"; \
	  [ -f "$$r" ] && { cfn-guard validate -d "$$t" -r "$$r" || exit 1; } || echo "(no guard rules yet)"; \
	done

verify-py: ## stdlib unittest for the registry upsert mapping
	@if [ -d registry/tests ]; then ( cd registry && python3 -m unittest discover -s tests -t . ); else echo "no python tests yet"; fi

verify-actions: ## actionlint for the workflows
	@if [ -d .github/workflows ]; then actionlint; else echo "no workflows yet"; fi

verify-aft: ## heavy: resolve the AFT module, then validate + fmt + tflint (the
           ## root is only a module call, so there is nothing for checkov to scan)
	@cd aft/aft-bootstrap && terraform init -backend=false && terraform validate && \
	  terraform fmt -check && tflint
