# AGENTS.md

This file is the operating contract for AI coding agents working in this
repository. Follow it together with `CONTRIBUTING.md`, `specs/README.md`, and
the active feature specs under `specs/features`.

## Repository Mission

ChessNotation is an iOS SwiftUI app for practicing standard algebraic chess
notation, timed notation, and square recognition from bundled game data. The
project is spec-driven: user-visible behavior, data contracts, and release
criteria should be defined in specs before implementation changes land.

## Current Architecture

- `ChessNotation/App`: app entry point, environment construction, and settings.
- `ChessNotation/Domain`: shared chess models and training-session summaries.
- `ChessNotation/Features`: SwiftUI feature screens, view models, and UI
  components.
- `ChessNotation/Services`: FEN parsing, SAN validation, and bundled game
  loading.
- `ChessNotation/Resources/Games`: bundled JSON game data, including evaluated
  variants.
- `ChessNotation/Assets.xcassets`: premium artwork, board textures, app icons,
  and chess-piece PNGs.
- `ChessNotationTests`: unit and integration tests.
- `ChessNotationUITests`: end-to-end UI tests.
- `specs/features`: active specs only.
- `specs/archive/features`: accepted or completed specs retained for history.

## Branch And Change Discipline

- Start feature/spec work from `main` unless the user says otherwise.
- Keep changes scoped to the requested task.
- Do not revert or overwrite unrelated user changes.
- Preserve existing file organization and naming conventions.
- Prefer focused changes over broad refactors.
- Do not introduce new dependencies unless the spec or user request makes the
  tradeoff explicit.
- When moving specs, preserve history with `git mv` when possible.

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

- `Draft`: exploration; coverage may be pending.
- `Proposed`: ready for review or implementation; coverage may be pending.
- `Accepted`: implemented or ready as a stable contract; every acceptance
  criterion must be covered.
- `Deprecated`: retained for history, no longer drives implementation.

## Implementation Guidelines

- Follow SwiftUI patterns already used in the project.
- Use `@State private var` for view-local mutable state.
- Use `let` for constants and immutable dependencies.
- Keep view models and domain models strongly typed.
- Prefer async/await APIs over Combine for new async work.
- Avoid force unwrapping.
- Keep comments sparse and useful.
- Preserve premium visual tokens in `PremiumDesign` instead of creating one-off
  styling.
- Preserve accessibility identifiers used by UI tests.
- Do not hand-roll chess rules unless the existing data-driven approach is
  enough for the requested behavior.

## Testing And Validation

Choose validation based on the change:

- Run `make spec-check` or `python3 scripts/spec_check.py` for any spec change.
- Run targeted unit tests for model, parser, validator, view-model, asset, or
  history changes.
- Run UI tests for navigation, accessibility identifiers, or user-flow changes.
- Use Xcode build/test tools when working from Xcode.
- If full test runs time out, run changed tests and then remaining suites in
  smaller groups.
- Report exactly what passed and what could not be run.

Important existing coverage areas:

- `NotationServicesTests`: FEN parsing, SAN normalization, game loading,
  settings persistence, engine-evaluation decoding.
- `GameViewModelIntegrationTests`: notation and timed-session state behavior.
- `SquareRecognitionTests`: square-recognition scoring, timing, result, and
  history behavior.
- `GameThumbnailPreviewTests`: game-specific thumbnail generation and fallback
  behavior.
- `PremiumAssetTests`: required premium artwork and chess-piece assets.
- `ChessNotationUITests`: primary navigation and training flows.

## Data And Asset Rules

- Bundled games are trusted source data. Do not silently rewrite game JSON.
- Evaluated game files contain stored engine evaluations; the app should not
  imply runtime engine analysis unless a future spec adds it.
- Keep generated or imported artwork in `Assets.xcassets`.
- Premium image names must remain stable when referenced by code or tests.
- Chess-piece PNGs must preserve transparency.
- If assets are missing, use existing fallback paths and make the fallback
  detectable in tests or code.

## Documentation Rules

- Update `README.md` for user-facing capabilities or high-level workflow
  changes.
- Update `CONTRIBUTING.md` for contributor process changes.
- Update `specs/README.md` for SDD process changes.
- Update `AGENTS.md` for AI-agent operating rules.
- Do not duplicate large spec content in multiple docs; link to the source of
  truth.

## Review Checklist For Agents

Before finishing a task:

- Confirm active specs reflect the requested behavior.
- Confirm accepted specs have no pending coverage.
- Run spec validation.
- Run relevant tests or explain why they were not run.
- Check `git status --short --branch`.
- Mention unrelated existing changes separately.
- Summarize files changed and the validation result.

## Current Active Work

At the time this file was added, accepted specs `CN-SPEC-0001` through
`CN-SPEC-0013` were archived under `specs/archive/features`, and
`CN-SPEC-0014` remained active in `specs/features`.
