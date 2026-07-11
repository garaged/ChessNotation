# CN-SPEC-0024: Notation Drill and Timed Variant Recovery

Status: Proposed
Owner: Project
Last updated: 2026-07-10

## Intent

Expose the richer notation and timed training engines already present in the codebase through deliberate setup flows, while preserving the current full-game and simple timed experiences as stable presets. Reuse current challenge generation, SAN validation, timing, scoring, history compatibility, and library indexing rather than building parallel game implementations. Every recovered mode must be a complete playable game with explicit finish conditions, meaningful results, replay, reconfiguration, and return behavior.

## Scope

In scope:

- A notation-training setup flow for full game, random position, focused drill, opening drill, and mistake review.
- A timed-training setup flow for legacy duration mode, sprint, accuracy race, survival, and combo.
- Intent-driven configuration models that map player goals to existing domain engines.
- Presets that preserve current launch behavior.
- Explicit session lifecycles, finish reasons, result screens, replay behavior, and safe exits.
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

## Playable Game Definitions

### Full Game Notation

- Starts after the player chooses a bundled game.
- Advances in trusted source move order.
- Finishes when the final expected move resolves, the player explicitly ends the session, or content becomes unavailable.
- On natural completion, transitions immediately to results after final feedback.
- Results show accuracy, first-try correctness, attempts, hints/reveals, average move time where available, and source game identity.
- Actions: `Play Again`, `Choose Another Game`, `View History`, and `Done`.

### Random Position Drill

- Uses a fixed configured prompt count.
- Each resolved prompt is independent and may come from a different source game.
- Finishes immediately after the configured final prompt resolves.
- Results show correctness, first-try count, average latency, mistake categories, and source diversity.
- Actions: `Play Again`, `Change Setup`, optional `Review Mistakes`, and `Done`.

### Focused Drill

- Uses a fixed prompt count and one selected move category or notation concept.
- Finishes after the final eligible prompt resolves or with `contentUnavailable` if the engine cannot supply enough prompts after bounded fallback.
- Results emphasize mastery of the chosen category, including mistakes by semantic SAN component.
- Actions: `Practice Again`, `Change Focus`, optional `Review Mistakes`, and `Done`.

### Opening Drill

- Uses a selected opening and opening-ply boundary with a fixed prompt count.
- Finishes after the configured count, explicit exit, or recoverable source exhaustion.
- Results identify opening, tested phase, correctness, and weak move categories without implying opening-engine analysis.
- Actions: `Repeat Opening`, `Choose Another Opening`, optional `Review Mistakes`, and `Done`.

### Mistake Review

- Builds a finite queue from eligible prior mistakes, with documented fallback to a general drill.
- Finishes when that queue or configured cap is exhausted.
- Results distinguish corrected items, repeated mistakes, and fallback prompts.
- Actions: `Review Again` when eligible mistakes remain, `Practice Something Else`, `View History`, and `Done`.

### Legacy Duration / Sprint

- Runs against an absolute deadline.
- Finishes exactly once at deadline, explicit exit, or unrecoverable content failure.
- A submission captured before the deadline may resolve; one at or after the deadline may not score.
- Results show score, completed prompts, correctness, moves per minute, streak, penalties, duration, and finish reason as available to the selected variant.
- Actions: `Run Again`, `Change Duration or Variant`, `View History`, and `Done`.

### Accuracy Race

- Uses a fixed challenge count and authoritative elapsed time.
- Finishes immediately after the final challenge resolves.
- Results show elapsed time, penalties, accuracy, first-try count, and final score breakdown.
- Actions: `Race Again`, `Change Setup`, `View History`, and `Done`.

### Survival

- Begins with configured time, modifies time through bounded bonuses and penalties, and escalates difficulty through existing stages.
- Finishes when authoritative remaining time reaches zero, when content becomes unavailable, or when the player exits.
- Results show survival duration, prompts cleared, highest stage, accuracy, streak, and score breakdown.
- Actions: `Try Again`, `Change Setup`, `View History`, and `Done`.

### Combo

- Uses a fixed prompt count or configured deadline, as defined by the selected existing combo configuration; the finish model must be explicit before launch.
- Finishes at that configured boundary and never remains active after the last scoreable prompt.
- Results show final score, best multiplier, longest streak, resets, accuracy, and penalties.
- Actions: `Build Another Combo`, `Change Setup`, `View History`, and `Done`.

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
- CN-SPEC-0024-FR016: VoiceOver must communicate intent, configuration consequences, disabled reasons, launch action, current selection, completion, and post-game actions without exposing expected SAN.
- CN-SPEC-0024-FR017: Existing home, library, gameplay, and timed UI tests must remain valid; new flows must add focused UI tests rather than replacing broad regression coverage.
- CN-SPEC-0024-FR018: Every mode must declare its authoritative finish condition before launch and expose progress toward that condition during play.
- CN-SPEC-0024-FR019: Resolving the final prompt must atomically record that resolution, finalize the result, save history at most once, and transition to results without requiring another tap intended for gameplay.
- CN-SPEC-0024-FR020: Timeout, final submission, explicit exit, lifecycle callbacks, and repeated finish requests must be idempotent and produce one terminal session state.
- CN-SPEC-0024-FR021: Results must be a stable screen or state with game-appropriate metrics and must always offer replay, reconfiguration or alternate selection, and return.
- CN-SPEC-0024-FR022: Replay must reuse the immutable effective configuration but create fresh challenge order/random state, timing state, counters, and persistence guards.
- CN-SPEC-0024-FR023: Explicit exit during active play must ask for confirmation when meaningful progress would be lost, then apply a documented `abandoned` save or discard policy consistently per mode.
- CN-SPEC-0024-FR024: A completed result must remain inspectable until the player chooses a next action; it must not auto-dismiss or auto-start another game.

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
- CN-SPEC-0024-AC012: Given VoiceOver, when navigating setup and playing a recovered mode, then intent, configuration, progress, feedback, finish state, and post-game actions are understandable without solution leakage.
- CN-SPEC-0024-AC013: Given the existing regression suites, when recovery is implemented, then full-game, legacy timed, history compatibility, SAN validation, and current navigation tests pass unchanged.
- CN-SPEC-0024-AC014: Given the final move of a full game resolves, when feedback completes, then results appear automatically with source-game and performance metrics and the player can replay, choose another game, view history, or finish.
- CN-SPEC-0024-AC015: Given the final prompt of random, focused, opening, mistake-review, accuracy-race, or fixed-count combo play resolves, then the final answer is counted exactly once and the game transitions directly to results.
- CN-SPEC-0024-AC016: Given sprint or survival time reaches zero, when timer callbacks are delayed, then authoritative time still ends the game once and the player is not left on an answerable board.
- CN-SPEC-0024-AC017: Given results are displayed, when replay is selected, then a fresh session starts with the same configuration and no prior timer, prompt, score, or finish state leaks.
- CN-SPEC-0024-AC018: Given results are displayed, when change setup or alternate selection is chosen, then the prior configuration is available for editing but no game starts until the player confirms.
- CN-SPEC-0024-AC019: Given results are displayed, when Done is chosen, then the complete session flow returns to its owning library or catalog and no timer or pending history operation remains active.
- CN-SPEC-0024-AC020: Given a player attempts to leave an active session, when exit is confirmed or cancelled, then the documented abandon/discard behavior occurs and the UI never traps the player or records a normal completion incorrectly.
- CN-SPEC-0024-AC021: Given source material becomes unavailable during bounded generation, when the session cannot continue, then it finishes with an explicit unavailable reason and offers setup and return actions rather than showing an inert last prompt.

## Planned Coverage

- `ChessNotationTests/NotationTrainingIntentMapperTests.swift`: CN-SPEC-0024-AC003, AC005, AC006, AC007, AC011.
- `ChessNotationTests/TimedTrainingIntentMapperTests.swift`: CN-SPEC-0024-AC004, AC008, AC009.
- `ChessNotationTests/NotationTrainingVarietyTests.swift`: CN-SPEC-0024-AC001, AC005, AC006, AC007, AC011, AC013, AC014, AC015, AC021.
- `ChessNotationTests/TimedNotationVariantTests.swift`: CN-SPEC-0024-AC002, AC008, AC009, AC013, AC015, AC016.
- `ChessNotationTests/NotationGameLifecycleTests.swift`: CN-SPEC-0024-AC014, AC015, AC017, AC018, AC019, AC020, AC021.
- `ChessNotationTests/TimedGameLifecycleTests.swift`: CN-SPEC-0024-AC009, AC015, AC016, AC017, AC018, AC019, AC020.
- `ChessNotationTests/NotationTrainingHistoryCompatibilityTests.swift`: CN-SPEC-0024-AC001, AC013.
- `ChessNotationTests/TimedNotationCompatibilityTests.swift`: CN-SPEC-0024-AC002, AC013.
- `ChessNotationUITests/NotationSetupUITests.swift`: CN-SPEC-0024-AC001, AC005, AC006, AC010, AC012, AC014, AC017, AC018, AC019, AC020.
- `ChessNotationUITests/TimedGameUITests.swift`: CN-SPEC-0024-AC002, AC004, AC008, AC012, AC013, AC016, AC017, AC018, AC019, AC020.
- Planned source owners: setup feature views/view models, typed intent mappers in Domain, game-specific result views, lifecycle coordinators or view-model states, and route resolution in App.

## Implementation Sequence

1. Add failing intent-mapper and preset-compatibility tests.
2. Add failing final-prompt, timeout, replay-reset, result-action, and active-exit lifecycle tests.
3. Add pure typed intent and effective-configuration mapping.
4. Add setup view models with explicit loading, ready, unavailable, and launch states.
5. Complete game-specific terminal states and result presentation before exposing each route.
6. Integrate notation setup while preserving the direct full-game preset.
7. Integrate timed setup while preserving legacy duration mode.
8. Add UI navigation, completion, replay, return, and accessibility tests.
9. Run spec check and all existing notation/timed regression suites before changing default presentation.

## Open Questions

- Whether the first tap opens a setup screen or a lightweight choice sheet with `Quick Start` and `Configure`. The chosen design must preserve one-step access to current behavior.
- Whether active-session abandonment is persisted for every mode or only for modes where partial progress is useful. The policy must be chosen explicitly per mode before implementation and covered by tests.

## Revision Notes

- 2026-07-10: Initial proposed spec for recovering accepted notation and timed engines into production navigation.
- 2026-07-10: Defined each mode as a complete game, including authoritative endings, result content, replay/reset behavior, setup return, safe exit, and anti-stuck tests.