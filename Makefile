SHELL := /bin/bash

.PHONY: build build-local sources lint test quality query diff quickstarts

build:
	chmod +x scripts/*.sh
	scripts/fetch_and_build.sh

build-local:
	@if [[ -z "$(SRC_A)" || -z "$(SRC_B)" ]]; then \
		echo "Usage: make build-local SRC_A=/path/to/repo-a SRC_B=/path/to/repo-b"; \
		exit 1; \
	fi
	chmod +x scripts/*.sh
	scripts/generate_usecases_index.sh --src-a "$(SRC_A)" --src-b "$(SRC_B)"

sources:
	@if [[ -z "$(SRC_A)" || -z "$(SRC_B)" ]]; then \
		echo "Usage: make sources SRC_A=/path/to/repo-a SRC_B=/path/to/repo-b"; \
		exit 1; \
	fi
	chmod +x scripts/*.sh
	scripts/generate_sources_report.sh --src-a "$(SRC_A)" --src-b "$(SRC_B)"

lint:
	bash -n scripts/*.sh tests/*.sh

test: lint
	bash tests/test_generate_usecases_index.sh
	bash tests/test_generate_sources_report.sh
	bash tests/test_generate_usecases_diff.sh
	bash tests/test_generate_quickstarts.sh

quality:
	chmod +x scripts/*.sh tests/*.sh
	scripts/run_quality_gates.sh --commands lint,test,build

query:
	@if [[ -z "$(Q)" ]]; then \
		echo "Usage: make query Q=<keyword> [CATEGORY=<分类>] [SOURCE=A|B] [RISK=low|medium|high] [MIN_CONFIDENCE=0] [MIN_REPRO=0] [LIMIT=20]"; \
		exit 1; \
	fi
	scripts/query_usecases.sh --keyword "$(Q)" --category "$(CATEGORY)" --source "$(SOURCE)" --risk "$(RISK)" --min-confidence "$(if $(MIN_CONFIDENCE),$(MIN_CONFIDENCE),0)" --min-repro "$(if $(MIN_REPRO),$(MIN_REPRO),0)" --limit "$(if $(LIMIT),$(LIMIT),20)"

diff:
	@if [[ -z "$(OLD)" || -z "$(NEW)" ]]; then \
		echo "Usage: make diff OLD=/path/old.json NEW=/path/new.json [OUT_MD=docs/DIFF.md] [OUT_JSON=docs/DIFF.json]"; \
		exit 1; \
	fi
	scripts/generate_usecases_diff.sh --old "$(OLD)" --new "$(NEW)" --out-md "$(if $(OUT_MD),$(OUT_MD),docs/DIFF.md)" --out-json "$(if $(OUT_JSON),$(OUT_JSON),docs/DIFF.json)"

quickstarts:
	scripts/generate_quickstarts.sh --index "$(if $(INDEX),$(INDEX),docs/USECASES.json)" --top "$(if $(TOP),$(TOP),20)" --out-md "$(if $(OUT_MD),$(OUT_MD),docs/QUICKSTARTS.md)" --out-json "$(if $(OUT_JSON),$(OUT_JSON),docs/QUICKSTARTS.json)"
