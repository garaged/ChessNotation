SHELL := /bin/bash

.PHONY: help spec-check specs

help:
	@printf '%s\n' \
		'Targets:' \
		'  make spec-check  Validate feature specs and coverage traceability' \
		'  make specs       Alias for spec-check'

spec-check:
	python3 scripts/spec_check.py

specs: spec-check
