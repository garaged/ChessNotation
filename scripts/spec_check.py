#!/usr/bin/env python3
"""Validate feature specs and coverage traceability."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FEATURE_DIR = ROOT / "specs" / "features"

FR_ID_RE = re.compile(r"\bCN-SPEC-\d{4}-FR\d{3}\b")
AC_ID_RE = re.compile(r"\bCN-SPEC-\d{4}-AC\d{3}\b")
TITLE_RE = re.compile(r"^#\s+(CN-SPEC-\d{4}):\s+(.+)$", re.MULTILINE)
STATUS_RE = re.compile(r"^Status:\s*(\w+)\s*$", re.MULTILINE)
COVERAGE_PATH_RE = re.compile(r"`([^`]+)`")

VALID_STATUSES = {"Draft", "Proposed", "Accepted", "Deprecated"}
REQUIRED_SECTIONS = {
    "Intent",
    "Scope",
    "Functional Requirements",
    "Acceptance Criteria",
    "Coverage",
    "Open Questions",
    "Revision Notes",
}


def section_names(text: str) -> set[str]:
    names = {
        line[3:].strip()
        for line in text.splitlines()
        if line.startswith("## ") and line[3:].strip()
    }
    if "Planned Coverage" in names:
        names.add("Coverage")
    return names


def section_body(text: str, section: str) -> str:
    candidates = [section]
    if section == "Coverage":
        candidates.append("Planned Coverage")

    for candidate in candidates:
        match = re.search(rf"^## {re.escape(candidate)}\s*$", text, re.MULTILINE)
        if not match:
            continue

        start = match.end()
        next_section = re.search(r"^##\s+", text[start:], re.MULTILINE)
        end = start + next_section.start() if next_section else len(text)
        return text[start:end]

    return ""


def ids_from_bullets(body: str, pattern: re.Pattern[str]) -> list[str]:
    ids: list[str] = []
    for line in body.splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            ids.extend(pattern.findall(stripped))
    return ids


def validate_spec(path: Path) -> list[str]:
    errors: list[str] = []
    rel_path = path.relative_to(ROOT)
    text = path.read_text(encoding="utf-8")

    title = TITLE_RE.search(text)
    if not title:
        errors.append(f"{rel_path}: missing title like '# CN-SPEC-0000: Title'")
        spec_id = None
    else:
        spec_id = title.group(1)
        if not path.name.startswith(f"{spec_id}-"):
            errors.append(f"{rel_path}: filename must start with {spec_id}-")

    status = STATUS_RE.search(text)
    if not status:
        errors.append(f"{rel_path}: missing 'Status: ...' line")
        status_value = None
    else:
        status_value = status.group(1)
        if status_value not in VALID_STATUSES:
            valid = ", ".join(sorted(VALID_STATUSES))
            errors.append(f"{rel_path}: invalid status '{status_value}', expected one of {valid}")

    raw_sections = {
        line[3:].strip()
        for line in text.splitlines()
        if line.startswith("## ") and line[3:].strip()
    }
    missing_sections = sorted(REQUIRED_SECTIONS - section_names(text))
    for section in missing_sections:
        errors.append(f"{rel_path}: missing section '## {section}'")

    if status_value == "Accepted" and "Coverage" not in raw_sections:
        errors.append(f"{rel_path}: accepted specs must use canonical section '## Coverage'")

    if not spec_id:
        return errors

    fr_body = section_body(text, "Functional Requirements")
    ac_body = section_body(text, "Acceptance Criteria")
    coverage_body = section_body(text, "Coverage")

    fr_ids = ids_from_bullets(fr_body, FR_ID_RE)
    ac_ids = ids_from_bullets(ac_body, AC_ID_RE)

    if not fr_ids:
        errors.append(f"{rel_path}: no functional requirement IDs found")
    if not ac_ids:
        errors.append(f"{rel_path}: no acceptance criterion IDs found")

    for found_id in fr_ids + ac_ids:
        if not found_id.startswith(spec_id):
            errors.append(f"{rel_path}: ID {found_id} does not match spec ID {spec_id}")

    for label, values in (("functional requirement", fr_ids), ("acceptance criterion", ac_ids)):
        duplicates = sorted({value for value in values if values.count(value) > 1})
        for duplicate in duplicates:
            errors.append(f"{rel_path}: duplicate {label} ID {duplicate}")

    coverage_paths = COVERAGE_PATH_RE.findall(coverage_body)
    if status_value == "Accepted":
        for coverage_path in coverage_paths:
            if not (ROOT / coverage_path).exists():
                errors.append(f"{rel_path}: coverage path does not exist: {coverage_path}")
        if not coverage_paths:
            errors.append(f"{rel_path}: accepted specs must list coverage paths")
        for ac_id in ac_ids:
            if ac_id not in coverage_body:
                errors.append(f"{rel_path}: accepted criterion missing from coverage: {ac_id}")

    return errors


def main() -> int:
    if not FEATURE_DIR.exists():
        print(f"Missing spec directory: {FEATURE_DIR.relative_to(ROOT)}", file=sys.stderr)
        return 1

    specs = sorted(FEATURE_DIR.glob("CN-SPEC-*.md"))
    if not specs:
        print("No feature specs found under specs/features", file=sys.stderr)
        return 1

    errors: list[str] = []
    seen_spec_ids: dict[str, Path] = {}

    for spec in specs:
        text = spec.read_text(encoding="utf-8")
        title = TITLE_RE.search(text)
        if title:
            spec_id = title.group(1)
            if spec_id in seen_spec_ids:
                first = seen_spec_ids[spec_id].relative_to(ROOT)
                errors.append(f"{spec.relative_to(ROOT)}: duplicate spec ID {spec_id}, first used in {first}")
            else:
                seen_spec_ids[spec_id] = spec

        errors.extend(validate_spec(spec))

    if errors:
        print("Spec check failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"Spec check passed: {len(specs)} feature spec(s) validated.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
