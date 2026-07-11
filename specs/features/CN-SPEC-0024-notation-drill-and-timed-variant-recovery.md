# CN-SPEC-0024: Notation Drill and Timed Variant Recovery

Status: Proposed
Owner: Project
Last updated: 2026-07-10

## Intent

Expose the richer notation and timed training engines already present in the codebase through deliberate setup flows, while preserving the current full-game and simple timed experiences as stable presets. Reuse current challenge generation, SAN validation, timing, scoring, history compatibility, and library indexing rather than building parallel game implementations.

## Scope

In scope:

- A notation-training setup flow for full game, random position, focused drill, opening drill, and mistake review.
- A timed-training setup flow for legacy duration mode, sprint, accuracy race, survival, and combo.
- Intent-driven configuration models that map player goals to existing domain engines.
- Presets that preserve current launch behavior.
- Results, history compatibility, recoverable empty states, accessibility, and targeted UI integration.

Out of scope:

- New SAN rules or runtime engine analysis.
- Replacing the bundled game library format.
- Online competition, Game Center, or cloud leaderboards.
- SAN Builder and non-notation mini-games owned by CN-SPEC-0025.

## Player Intents

The setup flows must begin with a player goal, not an implementation type:

- Practice a complete game in move order.
- Practice varied positions without playing a whole source game.
- Focus on one notation concept or move category.
- Reinforce a selected opening.
- Review previously missed material.
- Build speed for a fixed duration.
- Finish a fixed challenge set accurately and quickly.
- Survive escalating time pressure.
- Build and protect a scoring combo.

Each intent must resolve to an existing engine configuration through a typed mapper that can be unit tested without SwiftUI.

## Functional Requirements

- CN-SPEC-0024-FR001: The current Notation Training tile must continue to offer the existing full-game library path as the default or a one-step preset.
- CN-SPEC-0024-FR002: The current Timed Notation tile must continue to offer the existing duration-based experience as a legacy-compatible preset.
- CN-SPEC-0024-FR003: Notation setup must expose the session styles accepted by CN-SPEC-0016 only when their required content and capabilities are available.
- CN-SPEC-0024-FR004: Timed setup must expose the variants accepted by CN-SPEC-0017 and must clearly explain their distinct completion and scoring models.
- CN-SPEC-0024-FR005: Setup choices must map to `NotationTrainingConfiguration`, `TrainingChallenge` planning, timed-variant configuration, and existing history/result types through typed intent mappers.
- CN-SPEC-0024-FR006: No setup view may duplicate SAN normalization, challenge eligibility, scoring, timer, or history rules.
- CN-SPEC-0024-FR007: Existing bundled-library indexing must be reused across setup previews and session launch; repeated navigation must not rebuild the complete index synchronously.
- CN-SPEC-0024-FR008: Full-game mode must preserve current move order, attempts, hints, reveal/skip behavior, evaluation display, completion, and history compatibility.
- CN-SPEC-0024-FR009: Legacy timed mode must preserve duration selection, moves completed, accuracy, finish reason, moves per minute, and history decoding.
- CN-SPEC-0024-FR010: Setup must validate incompatible combinations before launch and explain why a choice is unavailable.
- CN-SPEC-0024-FR011: Empty or insufficient candidate sets must offer reset, broaden, or return actions and must never enter a loading loop.
- CN-SPEC-0024-FR012: Randomization and clocks must be injectable so setup-to-session integration tests remain deterministic.
- CN-SPEC-0024-FR013: Session launch must capture one immutable effective configuration for result/history traceability.
- CN-SPEC-0024-FR014: Exiting setup without launching must not write history or mutate game progress.
- CN-SPEC-0024-FR015: Returning from a completed session must preserve the selected setup long enough to replay or adjust it, without silently auto-starting.
- CN-SPEC-0024-FR016: VoiceOver must communicate intent, configuration consequences, disabled reasons, launch action, and current selection without exposing expected SAN.
- CN-SPEC-0024-FR017: Existing home, library, gameplay, and timed UI tests must remain valid; new flows must add focused UI tests rather than replacing broad regression coverage.

## Acceptance Criteria

- CN-SPEC-0024-AC001: Given Notation Training is launched with the current default action, when a library game is chosen, then current full-game behavior and history remain unchanged.
- CN-SPEC-0024-AC002: Given Timed Notation is launched with the legacy preset, when a duration is selected, then current duration-mode behavior and result fields remain unchanged.
- CN-SPEC-0024-AC003: Given each notation player intent, when mapped with deterministic dependencies, then it produces the expected existing domain configuration and no UI-only rule is required.
- CN-SPEC-0024-AC004: Given each timed player intent, when mapped, then it produces the expected sprint, accuracy-race, survival, combo, or legacy configuration.
- CN-SPEC-0024-AC005: Given a focused capture drill, when launched, then all generated prompts satisfy existing capture eligibility rules and results identify the selected intent and effective configuration.
- CN-SPEC-0024-AC006: Given an opening drill with insufficient material, when launch is attempted, then the setup remains usable and offers a documented broader fallback.
- CN-SPEC-0024-AC007: Given mistake review with no usable history, when launched, then existing general-drill fallback is used and the user is informed without failure.
- CN-SPEC-0024-AC008: Given delayed timer refresh or background transitions, when a recovered timed variant runs, then authoritative timing follows the existing injected-clock policy.
- CN-SPEC-0024-AC009: Given timeout and answer submission race, when a recovered timed variant finishes, then one result and one history write occur.
- CN-SPEC-0024-AC010: Given setup is opened and cancelled, when history is inspected, then no record was created and no current session state changed.
- CN-SPEC-0024-AC011: Given repeated setup navigation, when the same library is used, then the shared index is reused and prompt generation remains bounded.
- CN-SPEC-0024-AC012: Given VoiceOver, when navigating setup and playing a recovered mode, then intent, configuration, progress, feedback, and finish state are understandable without solution leakage.
- CN-SPEC-0024-AC013: Given the existing regression suites, when recovery is implemented, then full-game, legacy timed, history compatibility, SAN validation, and current navigation tests pass unchanged.

## Planned Coverage

- `ChessNotationTests/NotationTrainingIntentMapperTests.swift`: CN-SPEC-0024-AC003, AC005, AC006, AC007, AC011.
- `ChessNotationTests/TimedTrainingIntentMapperTests.swift`: CN-SPEC-0024-AC004, AC008, AC009.
- `ChessNotationTests/NotationTrainingVarietyTests.swift`: CN-SPEC-0024-AC001, AC005, AC006, AC007, AC011, AC013.
- `ChessNotationTests/TimedNotationVariantTests.swift`: CN-SPEC-0024-AC002, AC008, AC009, AC013.
- `ChessNotationTests/NotationTrainingHistoryCompatibilityTests.swift`: CN-SPEC-0024-AC001, AC013.
- `ChessNotationTests/TimedNotationCompatibilityTests.swift`: CN-SPEC-0024-AC002, AC013.
- `ChessNotationUITests/NotationSetupUITests.swift`: CN-SPEC-0024-AC001, AC005, AC006, AC010, AC012.
- `ChessNotationUITests/TimedGameUITests.swift`: CN-SPEC-0024-AC002, AC004, AC008, AC012, AC013.
- Planned source owners: setup feature views/view models, typed intent mappers in Domain, and route resolution in App.

## Implementation Sequence

1. Add failing intent-mapper and preset-compatibility tests.
2. Add pure typed intent and effective-configuration mapping.
3. Add setup view models with explicit loading, ready, unavailable, and launch states.
4. Integrate notation setup while preserving the direct full-game preset.
5. Integrate timed setup while preserving legacy duration mode.
6. Add UI navigation and accessibility tests.
7. Run spec check and all existing notation/timed regression suites before changing default presentation.

## Open Questions

- Whether the first tap opens a setup screen or a lightweight choice sheet with “Quick Start” and “Configure.” The chosen design must preserve one-step access to current behavior.

## Revision Notes

- 2026-07-10: Initial proposed spec for recovering accepted notation and timed engines into production navigation.
