# AGENTS.md

This file is the operating contract for AI coding agents working in this
repository. Follow it together with `CONTRIBUTING.md`, `specs/README.md`, and
the active feature specs under `specs/features`.

ChessNotation is spec-driven. User-visible behavior, data contracts, and release
criteria should be defined in specs before implementation changes land.

## Repository Mission

ChessNotation is an iOS SwiftUI app for practicing standard algebraic chess
notation, timed notation, and square recognition from bundled game data.

The project should remain simple, robust, testable, and ready for codebase
growth. Prefer small, well-factored changes over clever abstractions or broad
rewrites.

## Current Architecture

* `ChessNotation/App`: app entry point, dependency construction, environment
  setup, settings wiring, and top-level composition.
* `ChessNotation/Domain`: shared chess models, value types, training-session
  summaries, and pure domain rules.
* `ChessNotation/Features`: SwiftUI feature screens, view models, feature-local
  state, and reusable UI components.
* `ChessNotation/Services`: FEN parsing, SAN validation, bundled game loading,
  persistence helpers, and other infrastructure-facing logic.
* `ChessNotation/Resources/Games`: bundled JSON game data, including evaluated
  variants.
* `ChessNotation/Assets.xcassets`: premium artwork, board textures, app icons,
  and chess-piece PNGs.
* `ChessNotationTests`: unit and integration tests.
* `ChessNotationUITests`: end-to-end UI tests.
* `specs/features`: active specs only.
* `specs/archive/features`: accepted or completed specs retained for history.

## Architecture Principles

Use these principles to keep the codebase maintainable as it grows:

* Keep dependency direction clear:

  * `App` may depend on `Features`, `Services`, and `Domain`.
  * `Features` may depend on `Domain` and service protocols.
  * `Services` may depend on `Domain`.
  * `Domain` must not depend on SwiftUI, app settings, assets, persistence,
    networking, file loading, or UI concepts.
* Keep domain models pure and strongly typed. Prefer value types for chess
  concepts, training results, settings values, and parsed data.
* Keep SwiftUI views focused on layout, presentation, and user interaction.
  Move business logic, parsing, scoring, validation, and state transitions out
  of view bodies.
* Prefer feature-level view models for non-trivial screen behavior.
* Prefer protocol-based boundaries when a feature depends on loading,
  validation, persistence, clock/timer behavior, randomization, or other
  side-effecting services.
* Avoid global mutable state. Pass dependencies explicitly through initializers,
  environment values, or composition roots.
* Keep feature modules cohesive. A feature should own its screen-specific state,
  view model, helper views, and tests.
* Do not introduce cross-feature coupling just to share a small helper. Shared
  abstractions should be earned by repeated, stable usage.
* Avoid premature generalization. Follow KISS first, then extract reusable
  abstractions when duplication becomes meaningful.
* Follow DRY for business rules and data contracts, but do not over-abstract
  simple UI repetition if readability would suffer.
* Follow SOLID pragmatically:

  * Single Responsibility: types should have one clear reason to change.
  * Open/Closed: prefer adding new strategies or services over modifying large
    conditional blocks when behavior families grow.
  * Liskov Substitution: protocol conformers must preserve expected behavior.
  * Interface Segregation: keep protocols small and feature-oriented.
  * Dependency Inversion: high-level feature logic should depend on protocols
    for side-effecting services.
* Prefer composition over inheritance.
* Prefer explicit names over clever shorthand.
* Prefer readable control flow over dense functional chains when behavior is
  non-trivial.

## Branch And Change Discipline

* Start feature/spec work from `main` unless the user says otherwise.
* Keep changes scoped to the requested task.
* Do not revert, overwrite, or reformat unrelated user changes.
* Preserve existing file organization and naming conventions unless the task is
  specifically about restructuring.
* Prefer focused changes over broad refactors.
* Do not introduce new dependencies unless the spec or user request makes the
  tradeoff explicit.
* If adding a dependency is truly necessary, explain why and prefer small,
  well-maintained packages.
* Do not change bundle identifiers, signing settings, deployment targets,
  entitlements, app groups, or capabilities unless explicitly requested.
* When moving specs, preserve history with `git mv` when possible.
* Before finishing, check `git status --short --branch` and call out unrelated
  existing changes separately.

## Spec-Driven Development Workflow

Use this workflow for any user-visible feature, behavior change, data contract,
or release criterion:

1. Inspect active specs in `specs/features` and relevant archived specs in
   `specs/archive/features`.
2. If no active spec covers the work, create or update a spec before changing
   implementation.
3. Use the next available `CN-SPEC-0000` identifier for new specs.
4. Keep active specs in `specs/features`.
5. Move accepted/completed specs to `specs/archive/features` when the active
   tree should focus on remaining work.
6. Keep acceptance criteria concrete and testable.
7. Update `Coverage` so each accepted criterion points to at least one existing
   test, fixture, source file, asset folder, or verification artifact.
8. Run `make spec-check` or `python3 scripts/spec_check.py`.

Spec statuses:

* `Draft`: exploration; coverage may be pending.
* `Proposed`: ready for review or implementation; coverage may be pending.
* `Accepted`: implemented or ready as a stable contract; every acceptance
  criterion must be covered.
* `Deprecated`: retained for history, no longer drives implementation.

## Swift And SwiftUI Guidelines

* Follow SwiftUI patterns already used in the project.
* Use `@State private var` for view-local mutable state.
* Use `@StateObject` or equivalent ownership patterns when a view owns a
  long-lived view model.
* Use `@ObservedObject`, `@EnvironmentObject`, or environment values only when
  ownership and lifetime are clear.
* Use `let` for constants and immutable dependencies.
* Keep view models and domain models strongly typed.
* Prefer async/await APIs over Combine for new async work unless the surrounding
  code already uses Combine.
* Avoid force unwrapping. If a force unwrap is truly safe, keep the invariant
  obvious nearby.
* Avoid force casts. Prefer typed models, failable initializers, guards, or
  explicit error handling.
* Prefer `private` and `fileprivate` to keep implementation details scoped.
* Keep comments sparse and useful. Explain why, not what.
* Keep view bodies readable. Extract subviews or computed properties when a
  view body becomes hard to scan.
* Avoid putting expensive computation directly in SwiftUI view bodies.
* Preserve premium visual tokens in `PremiumDesign` instead of creating one-off
  styling.
* Preserve accessibility identifiers used by UI tests.
* When adding UI, include accessibility labels, traits, and identifiers where
  the view participates in tested user flows.
* Do not hand-roll chess rules unless the existing data-driven approach is not
  enough for the requested behavior and the spec explicitly requires it.

## Feature Design Guidelines

For new or expanded features:

* Start from the spec and acceptance criteria.
* Model the feature state explicitly.
* Keep state transitions testable outside the UI when practical.
* Prefer small view models with clear inputs and outputs.
* Keep feature-specific helper types near the feature until they become broadly
  useful.
* Put reusable chess concepts in `Domain`, not inside feature folders.
* Put parsing, file loading, persistence, and other side effects in `Services`,
  behind protocols when they are consumed by features.
* Avoid large "manager" or "god" types. Split responsibilities by behavior.
* Avoid adding broad shared utilities without at least two real call sites.
* Preserve backward compatibility for existing bundled data unless a spec says
  otherwise.
* Make fallback behavior explicit and testable.

## Error Handling And State

* Represent recoverable errors explicitly.
* Prefer user-safe error messages in UI-facing paths.
* Do not silently ignore parsing, loading, or validation failures unless the
  fallback is intentional and tested.
* Keep loading, empty, success, and error states distinguishable in view models.
* Avoid using optional values to represent many different states. Prefer enums
  when state has meaningful cases.
* Do not crash on malformed bundled data; fail predictably and make the issue
  observable in tests or diagnostics.

## Testing And Validation

Choose validation based on the change:

* Run `make spec-check` or `python3 scripts/spec_check.py` for any spec change.
* Run targeted unit tests for model, parser, validator, view-model, asset, or
  history changes.
* Run UI tests for navigation, accessibility identifiers, or user-flow changes.
* Use Xcode build/test tools when working from Xcode.
* If full test runs time out, run changed tests and then remaining suites in
  smaller groups.
* Report exactly what passed and what could not be run.

Testing expectations:

* Bug fixes should include regression coverage when practical.
* New business logic should have unit tests.
* New or changed view-model behavior should have unit tests.
* Parser, validator, scoring, timer, history, and persistence behavior should be
  tested outside the UI whenever possible.
* UI tests should cover major user flows, not every visual variation.
* Asset-dependent behavior should have tests for required assets and fallback
  behavior.
* Refactors should preserve behavior and pass existing tests.
* If tests cannot be run, explain why and list the exact commands that should
  be run.

Important existing coverage areas:

* `NotationServicesTests`: FEN parsing, SAN normalization, game loading,
  settings persistence, engine-evaluation decoding.
* `GameViewModelIntegrationTests`: notation and timed-session state behavior.
* `SquareRecognitionTests`: square-recognition scoring, timing, result, and
  history behavior.
* `GameThumbnailPreviewTests`: game-specific thumbnail generation and fallback
  behavior.
* `PremiumAssetTests`: required premium artwork and chess-piece assets.
* `ChessNotationUITests`: primary navigation and training flows.

## Data And Asset Rules

* Bundled games are trusted source data. Do not silently rewrite game JSON.
* Evaluated game files contain stored engine evaluations; the app should not
  imply runtime engine analysis unless a future spec adds it.
* Preserve existing JSON data contracts unless a spec explicitly changes them.
* If changing a data contract, update specs, fixtures, decoding tests, and any
  fallback behavior.
* Keep generated or imported artwork in `Assets.xcassets`.
* Premium image names must remain stable when referenced by code or tests.
* Chess-piece PNGs must preserve true transparency.
* Do not replace production assets with placeholders unless explicitly asked.
* If assets are missing, use existing fallback paths and make the fallback
  detectable in tests or code.

## Documentation Rules

* Update `README.md` for user-facing capabilities or high-level workflow
  changes.
* Update `CONTRIBUTING.md` for contributor process changes.
* Update `specs/README.md` for SDD process changes.
* Update `AGENTS.md` for AI-agent operating rules.
* Do not duplicate large spec content in multiple docs; link to the source of
  truth.
* Keep documentation changes close to the behavior they describe.

## Generated Files And Tooling

* Do not edit generated files manually.
* Do not modify Xcode project structure, schemes, or build settings unless the
  task requires it.
* Do not update lockfiles or package metadata unless dependencies changed.
* Do not add scripts that duplicate existing Makefile or spec-check behavior
  without a clear reason.
* Prefer existing repository tools over inventing new commands.

## Security And Privacy

* Never commit secrets, tokens, certificates, provisioning profiles, private
  keys, or local credentials.
* Do not log sensitive user data.
* Do not add analytics, tracking, telemetry, networking, or external service
  calls unless a spec or user request explicitly requires it.
* Keep local app data handling simple and transparent.
* Treat future Game Center, cloud sync, account, or purchase-related changes as
  privacy-sensitive and spec-required.

## Review Checklist For Agents

Before finishing a task:

* Confirm active specs reflect the requested behavior.
* Confirm accepted specs have no pending coverage.
* Confirm architecture boundaries were preserved.
* Confirm no unrelated formatting or rewrites were introduced.
* Run spec validation when specs changed.
* Run relevant tests or explain why they were not run.
* Check `git status --short --branch`.
* Mention unrelated existing changes separately.
* Summarize files changed and the validation result.
* Call out risks, migrations, compatibility concerns, or follow-up work.

## Current Active Work

At the time this file was added, accepted specs `CN-SPEC-0001` through
`CN-SPEC-0013` were archived under `specs/archive/features`, and
`CN-SPEC-0014` remained active in `specs/features`.
