# Game Recovery Audit: `e423bb4` to `main`

Date: 2026-07-10
Baseline: `e423bb44c4d7ed82a17a6400d8617622e11ff79f`
Current target: `main`

## Purpose

Identify game experiences that should be recovered into the current app without regressing the existing home experience, replacing stronger current implementations, or duplicating engines that already exist.

## Comparison Result

The baseline commit is an ancestor of `main`. The baseline home exposed:

1. Notation Training
2. Timed Notation
3. Square Recognition
4. Instructions

Current `main` keeps those paths and additionally exposes Piece Movement and Position Recall. Therefore, none of the baseline's visible games should be restored by copying historical UI or reverting current code.

The recovery opportunity is instead the gap between current domain/feature engines and what users can launch or configure from the app.

## Current Recovery Candidates

### A. Configurable notation drills

Current code and accepted specifications define full-game, random-position, focused, opening, and mistake-review styles. The home path still launches the legacy library-first experience directly, so the richer drill planner is not presented as a first-class setup flow.

Disposition: recover through a new setup and routing layer that reuses `NotationTraining`, `TrainingChallenge`, existing SAN validation, bundled-game indexing, history compatibility, and `NotationDrillSession`.

### B. Timed notation variants

Current code and accepted specifications define sprint, accuracy race, survival, and combo engines. The visible timed path still presents the legacy duration-based configuration.

Disposition: recover through a variant-selection setup flow while preserving the current simple duration mode as a legacy-compatible preset.

### C. SAN Builder

Current code contains SAN decomposition, parsing, result, and test foundations, but no production home route or complete user-facing game flow is visible.

Disposition: recover as a mini-game using the shared SAN validation boundary and existing challenge generation rather than creating an independent move parser.

### D. Expanded square-recognition drills

Current code contains expanded square-recognition session and view-model foundations beyond the baseline coordinate-tap game. The visible route continues to use the established setup path.

Disposition: integrate the expanded variants behind the existing Square Recognition identity and visual language. Do not create a competing duplicate tile unless usability testing proves a separate entry point is clearer.

### E. Position Recall breadth

Current `main` exposes reconstruction with fixed beginner configuration and a small in-code snapshot set. Existing domain work also describes locate-piece, occupant, occupied-subset, and reconstruction question types.

Disposition: evolve the existing Position Recall tile into a setup-driven family of recall games. Preserve the current reconstruction behavior as a default preset and reuse the existing reconstruction view model, clock, history, and board rendering.

## Explicit Non-Recovery Decisions

- Do not restore the historical `HomeView` over `RestoredHomeView`.
- Do not replace current Piece Movement or Position Recall implementations with older or less complete code.
- Do not fork SAN normalization, FEN parsing, board orientation, history persistence, scoring, timing, or challenge-generation rules.
- Do not change existing game identifiers or history decoding without a compatibility migration and tests.
- Do not make Instructions a game or move it into game scoring/history.
- Do not expose internal engines merely because they exist; every route must have a coherent user intent, setup, result, and recovery state.

## Recommended Delivery Order

1. CN-SPEC-0023: game catalog, routing, and regression contract.
2. CN-SPEC-0024: notation drill and timed-variant recovery.
3. CN-SPEC-0025: SAN Builder and expanded mini-game recovery.

Each implementation slice should be independently shippable, test-first, and traceable from intent to acceptance criterion to test and source coverage.
