# Spec-Driven Development

Specs are the product contract for this repository. A feature change should
start by adding or updating a spec, then implementation and tests should trace
back to that spec.

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
