SHELL := /bin/bash

.PHONY: help spec-check specs validate-home-assets

help:
	@printf '%s\n' \
		'Targets:' \
		'  make spec-check  Validate feature specs and coverage traceability' \
		'  make specs       Alias for spec-check' \
		'  make validate-home-assets  Validate normalized Home tile image metadata'

spec-check:
	python3 scripts/spec_check.py

specs: spec-check

validate-home-assets:
	.venv/bin/python scripts/validate_home_tile_assets.py
