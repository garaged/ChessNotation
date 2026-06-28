# Spec-Driven Development

Specs are the product contract for this repository. A feature change should
start by adding or updating a spec, then implementation and tests should trace
back to that spec.

AI agents must also follow the repository operating contract in
[`AGENTS.md`](../AGENTS.md).

## Workflow

1. Copy `specs/templates/feature-spec.md` into `specs/features/`.
2. Give it the next `CN-SPEC-0000` identifier.
3. Fill out intent, scope, requirements, acceptance criteria, and coverage.
4. Run the checker:

   ```sh
   python3 scripts/spec_check.py
   ```

5. Implement the change and update tests until the coverage section accurately
   points to the files that protect each acceptance criterion.
6. When an accepted spec is complete and no longer active work, move it to
   `specs/archive/features/` so `specs/features/` stays focused on current
   work.

## Spec Status

- `Draft`: early exploration, may have open questions and incomplete coverage.
- `Proposed`: ready for review, requirements and acceptance criteria should be
  stable.
- `Accepted`: ready to build or already implemented; every acceptance criterion
  must be listed in coverage.
- `Deprecated`: retained for history, no longer drives implementation.

## Traceability Rules

The checker enforces these rules for every feature spec:

- The filename starts with the same `CN-SPEC-0000` ID used in the title.
- Required sections are present.
- Status is one of the supported values.
- Functional requirement IDs use `CN-SPEC-0000-FR000`.
- Acceptance criterion IDs use `CN-SPEC-0000-AC000`.
- Every path listed in `Coverage` exists.
- Accepted specs mention every acceptance criterion in `Coverage`.

## Scope

Use specs for user-visible behavior, data contracts, domain logic, and release
criteria. Do not create specs for purely mechanical refactors unless they
change an observable contract.

## Active And Archived Specs

- `specs/features/`: active `Draft`, `Proposed`, or currently relevant
  `Accepted` specs.
- `specs/archive/features/`: accepted or completed specs retained for history
  and traceability.

The checker validates active specs in `specs/features/`. Archived specs should
remain readable and internally consistent, but they are not part of the active
validation set.

## AI Agent Expectations

- Inspect the active spec tree before changing user-visible behavior.
- Read archived specs when they define behavior related to the requested change.
- Keep acceptance criteria concrete and testable.
- Update coverage whenever implementation or tests change.
- Run `make spec-check` or `python3 scripts/spec_check.py` before handoff.
- Report test commands and results in the final response.
