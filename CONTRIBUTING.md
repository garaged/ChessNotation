# Contributing

## Ground rules

- Keep changes focused and reviewable.
- Prefer small pull requests with clear intent.
- Add or update tests when behavior changes.
- Preserve the existing SwiftUI and Swift naming/style conventions.

## Development workflow

1. Create a branch from `main`.
2. Add or update the relevant feature spec under `specs/features`.
3. Run `make spec-check` and resolve spec or traceability issues.
4. Make the smallest viable implementation change.
5. Run the relevant tests in Xcode.
6. Update docs if user-visible behavior changed.
7. Open a pull request with a short description, screenshots when UI changed, and test notes.

## Spec expectations

- Feature specs should define intent, scope, functional requirements, acceptance criteria, and coverage.
- Accepted specs must trace every acceptance criterion to at least one coverage file.
- Use `specs/templates/feature-spec.md` for new feature specs.

## Testing expectations

- Unit tests should cover deterministic logic.
- Integration tests should cover feature state changes across multiple components.
- UI tests should cover primary user flows and regressions worth protecting.

## Licensing

By contributing to this repository, you agree that your contributions will be licensed under the GNU GPL v3.0 used by this project.
