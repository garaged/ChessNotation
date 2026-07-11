# CN-SPEC-0025: SAN Builder and Expanded Mini-game Recovery

Status: Proposed
Owner: Project
Last updated: 2026-07-10

## Intent

Complete and expose the mini-game experiences that are already supported by current domain and feature foundations: SAN Builder, expanded Square Recognition drills, and the broader Position Recall family. Keep the same quiet, premium training feel as current mini-games, preserve current defaults, and reuse shared chess, timing, board, history, and challenge engines. A recovered mini-game must be fully playable from setup through a deliberate result and next action; exposing a partial engine or leaving the player on the final board is not sufficient.

## Scope

In scope:

- A production SAN Builder setup, session, result, history, replay, and exit flow.
- Expanded Square Recognition variants integrated under the current Square Recognition identity.
- Position Recall setup for locate-piece, square-occupant, occupied-subset, and reconstruction questions.
- Existing Piece Movement and current Position Recall reconstruction as regression anchors.
- Explicit finish conditions, terminal feedback, result actions, replay reset, and interruption handling for every recovered mini-game.
- Shared mini-game setup and lifecycle conventions where repeated, stable behavior justifies them.
- Deterministic generation, accessibility, recoverable content states, and complete test traceability.

Out of scope:

- Runtime chess-engine analysis, tactic verification, or complete legal-position search.
- Replacing the existing board/piece assets or premium design system.
- Rewriting Piece Movement unless required for shared routing compatibility.
- A generic mini-game framework that obscures game-specific rules.

## Player Intents

- Learn how SAN is assembled from meaningful components.
- Recognize board coordinates faster from either orientation.
- Recall where a specific piece was located.
- Identify what occupied a remembered square.
- Recall a bounded set of occupied squares.
- Reconstruct a bounded hidden subset of a position.

Each intent must map to a game-specific typed configuration. Shared setup abstractions may cover only stable concepts such as difficulty, orientation, prompt limit, random source, clock, history destination, completion reason, and post-game actions.

## Playable Mini-game Definitions

### SAN Builder

- Starts from a configured difficulty and finite prompt count.
- Presents one trusted SAN challenge at a time as ordered semantic components.
- A prompt resolves when the assembled answer validates, attempts are exhausted, or the player explicitly reveals/skips where allowed.
- The game finishes immediately after the configured final prompt resolves, on explicit exit, or on bounded content unavailability.
- Results show correctness, first-try completions, component-mistake categories, average assembly time, hints/reveals, difficulty, and finish reason.
- Actions: `Build Again`, `Change Setup`, optional `Review Mistakes`, `View History`, and `Done`.

### Square Recognition: Current Coordinate Tap

- Preserves the current quick-start rules and configured prompt count.
- Finishes after the final square resolves or through the current documented exit behavior.
- Results and replay behavior remain backward compatible.

### Expanded Square Recognition

- Each variant must have a finite configured prompt count and a clearly described answer interaction.
- A prompt resolves through existing square-recognition scoring and orientation mapping.
- The game finishes immediately after the final prompt resolves.
- Results show accuracy, first-try count, average response time, orientation, variant, streak where supported, and error distribution by file/rank or relevant category.
- Actions: `Play Again`, `Change Drill`, `View History`, and `Done`.

### Position Recall: Locate Piece

- Shows a validated position for the configured study duration, hides the answer, then asks for one unambiguous piece location.
- A prompt resolves after a submitted square or documented reveal/skip behavior.
- The game finishes after the configured final prompt resolves.
- Results show correct locations, near/mislocated answers where representable, latency after concealment, study duration, and orientation.
- Actions: `Recall Again`, `Change Setup`, optional `Review Misses`, and `Done`.

### Position Recall: Square Occupant

- Shows a validated position, conceals it, and asks which piece or empty state occupied one square.
- The answer set must include an explicit empty option when applicable.
- The game finishes after the configured final prompt resolves.
- Results show correct occupants, piece/color confusions, empty-square errors, latency, study duration, and orientation.
- Actions: `Recall Again`, `Change Setup`, optional `Review Misses`, and `Done`.

### Position Recall: Occupied Subset

- Shows a validated position or bounded region, conceals it, and asks the player to select the exact occupied-square set.
- Submission is explicit so selecting the final correct square does not accidentally bypass review of the set.
- A prompt resolves from exact set comparison, recording missing and extra squares separately.
- The game finishes after the configured final prompt resolves.
- Results show exact reconstructions, missing-square count, extra-square count, latency, study duration, and orientation.
- Actions: `Recall Again`, `Change Setup`, optional `Review Misses`, and `Done`.

### Position Recall: Reconstruction

- Preserves the current beginner quick-start preset while allowing configured difficulty, study duration, prompt count, and orientation.
- After study, the player places the bounded hidden subset and submits explicitly.
- A prompt resolves through order-independent expected-placement comparison, recording missing, extra, and wrong-piece placements separately.
- The game finishes after the configured final prompt resolves and must not leave the reconstructed board as an inert active screen.
- Results show exact reconstructions, placement-error categories, latency, study duration, difficulty, orientation, and finish reason.
- Actions: `Reconstruct Again`, `Change Setup`, optional `Review Misses`, `View History`, and `Done`.

## Functional Requirements

- CN-SPEC-0025-FR001: SAN Builder must be reachable from the mini-game catalog with a coherent setup and must use existing SAN decomposition and shared SAN validation.
- CN-SPEC-0025-FR002: SAN Builder must never accept answers through UI string equality alone or maintain a separate normalization implementation.
- CN-SPEC-0025-FR003: SAN Builder distractors and component progression must derive from existing difficulty and challenge rules and must not reveal unresolved later components.
- CN-SPEC-0025-FR004: Square Recognition must preserve the current coordinate-tap game as its default preset and add expanded drills within the same feature identity.
- CN-SPEC-0025-FR005: Expanded square drills must reuse existing board coordinate mapping, orientation behavior, scoring, result, and history boundaries.
- CN-SPEC-0025-FR006: Position Recall must preserve the current beginner reconstruction preset and expose locate-piece, occupant, occupied-subset, and reconstruction intents when eligible source material exists.
- CN-SPEC-0025-FR007: Position Recall setup must use existing question generation, reconstruction session, injected clock, hidden-answer protections, and history stores rather than parallel implementations.
- CN-SPEC-0025-FR008: Current fixed in-code reconstruction snapshots may remain as deterministic fallback fixtures, but production prompt generation should prefer validated bundled positions through an existing reusable index where available.
- CN-SPEC-0025-FR009: Every hidden-position mode must remove concealed piece labels, accessibility values, hit targets, debug descriptions, and overlays after the study phase.
- CN-SPEC-0025-FR010: Prompt generation must be bounded, deterministic under injected randomness, and able to reject ambiguous or invalid source positions.
- CN-SPEC-0025-FR011: Setup must present explicit unavailable reasons when a mode lacks eligible prompts and must offer another mode or broader configuration.
- CN-SPEC-0025-FR012: Results must preserve stable game identity plus intent, difficulty, orientation, prompt count, correctness, first-try/component mistakes, latency, study duration, and finish reason as applicable.
- CN-SPEC-0025-FR013: Existing Piece Movement scoring, geometry, beginner preset, history, navigation, completion, and result behavior must remain unchanged.
- CN-SPEC-0025-FR014: Existing Square Recognition and Position Recall history must remain readable; new fields require defaults and compatibility tests.
- CN-SPEC-0025-FR015: UI and view models must expose loading, study, answering, feedback, completion, unavailable, results, replay, and exit states explicitly where applicable.
- CN-SPEC-0025-FR016: Views must reuse current board components, `PremiumDesign`, tile art/fallbacks, reduced-motion behavior, haptic settings, and accessibility conventions.
- CN-SPEC-0025-FR017: A shared mini-game abstraction may be introduced only after at least two recovered games demonstrate identical lifecycle or setup behavior; scoring and answer evaluation remain game-specific.
- CN-SPEC-0025-FR018: Current mini-game UI tests must continue to pass, and each recovered intent must add at least one deterministic unit/integration test plus one representative navigation UI test.
- CN-SPEC-0025-FR019: Every mini-game must declare a finite or depletion-based completion model before launch; unbounded play requires an explicit endless-mode spec and is not implied by recovery.
- CN-SPEC-0025-FR020: Resolving the final prompt must count its outcome exactly once, finalize and persist at most one result, and transition directly to results after any required final feedback.
- CN-SPEC-0025-FR021: Results must be a stable screen or explicit terminal state and must offer same-configuration replay, configuration change, and return to the mini-game catalog.
- CN-SPEC-0025-FR022: Replay must create a fresh session with reset prompt sequence, study deadline, selections, placements, scoring, counters, hidden-answer state, and persistence guards.
- CN-SPEC-0025-FR023: Leaving during study, answer, or feedback must cancel active clocks/callbacks and apply a documented abandon or discard policy without saving a normal completion.
- CN-SPEC-0025-FR024: A content-generation failure after play begins must transition to an explicit unavailable finish state with setup and return actions; it must not strand the player on the previous prompt.
- CN-SPEC-0025-FR025: The completed result remains visible until the player selects a next action and must not automatically dismiss or begin another session.

## Acceptance Criteria

- CN-SPEC-0025-AC001: Given representative SAN fixtures, when SAN Builder components are selected correctly, then shared SAN validation accepts the assembled answer and the result records no component mistakes.
- CN-SPEC-0025-AC002: Given an incorrect SAN component, when feedback is shown, then the incorrect category is identified without revealing unresolved components or the complete SAN.
- CN-SPEC-0025-AC003: Given the existing Square Recognition quick-start preset, when launched after recovery, then current coordinate-tap rules, orientation, scoring, history, completion, and identifiers remain unchanged.
- CN-SPEC-0025-AC004: Given each expanded square-recognition intent and deterministic prompts, when a session runs, then scoring and result metadata follow existing square-recognition domain rules.
- CN-SPEC-0025-AC005: Given the existing Position Recall quick-start preset, when launched after recovery, then the current beginner reconstruction configuration remains equivalent.
- CN-SPEC-0025-AC006: Given locate-piece, occupant, occupied-subset, and reconstruction intents, when eligible deterministic fixtures are used, then each produces one unambiguous expected answer or set.
- CN-SPEC-0025-AC007: Given a delayed study timer callback, when authoritative time passes the deadline, then the hidden phase begins exactly once through the existing injected-clock policy.
- CN-SPEC-0025-AC008: Given any hidden recall phase with VoiceOver enabled, when the accessibility hierarchy is inspected, then concealed answer data is absent while answer controls remain usable.
- CN-SPEC-0025-AC009: Given ambiguous, malformed, or insufficient source positions, when prompts are generated, then they are rejected within bounded work and setup offers a recoverable alternative.
- CN-SPEC-0025-AC010: Given completed recovered mini-games, when results are saved and restored, then stable identity, intent, configuration, metrics, and finish reason are preserved.
- CN-SPEC-0025-AC011: Given legacy Square Recognition and Position Recall records, when loaded after new fields are introduced, then existing data remains visible with documented defaults.
- CN-SPEC-0025-AC012: Given Piece Movement regression fixtures, when mini-game routing and any shared setup abstractions are introduced, then movement destinations, scoring, beginner preset, history, completion, and result behavior remain unchanged.
- CN-SPEC-0025-AC013: Given compact and regular width devices, when recovered mini-games are used, then board interaction, component controls, feedback, and result layouts remain readable and preserve the current premium visual character.
- CN-SPEC-0025-AC014: Given long deterministic mini-game sessions, when prompt generation and history aggregation run, then memory and retained result data remain bounded and immediate duplicates are avoided where possible.
- CN-SPEC-0025-AC015: Given the final SAN Builder prompt resolves, when final feedback completes, then results appear automatically with component-mistake metrics and actions to replay, configure, review where available, or finish.
- CN-SPEC-0025-AC016: Given the final expanded Square Recognition prompt resolves, then the answer is scored once and the player reaches results without needing to tap a disabled or nonexistent next-prompt control.
- CN-SPEC-0025-AC017: Given the final locate-piece or occupant recall answer resolves, then concealed position data remains protected while the result transition occurs and the session cannot accept another answer.
- CN-SPEC-0025-AC018: Given an occupied-subset or reconstruction prompt, when the player submits the exact or incorrect set on the final prompt, then missing/extra/wrong-piece metrics are finalized once and results appear.
- CN-SPEC-0025-AC019: Given results are displayed, when replay is selected, then a fresh same-configuration session begins with no study timer, selection, board placement, score, or concealed-answer state leaking from the prior run.
- CN-SPEC-0025-AC020: Given results are displayed, when change setup is selected, then the previous configuration is editable and no new session starts before confirmation.
- CN-SPEC-0025-AC021: Given results are displayed, when Done is selected, then the full mini-game flow returns to the mini-game catalog and no timer, callback, or pending history operation remains active.
- CN-SPEC-0025-AC022: Given the player exits during study or active answering, when exit is confirmed, then clocks and pending transitions stop and the documented abandon/discard policy is applied without a normal-completion record.
- CN-SPEC-0025-AC023: Given prompt generation fails after at least one prompt, when no valid next prompt can be produced within bounds, then the session ends with an explicit unavailable result and offers change-setup and return actions.

## Planned Coverage

- `ChessNotationTests/SANBuilderViewModelTests.swift`: CN-SPEC-0025-AC001, AC002, AC009, AC010, AC015, AC019, AC020, AC022, AC023.
- `ChessNotationTests/NotationConceptGameTests.swift`: CN-SPEC-0025-AC001, AC002, AC006, AC010, AC014, AC015.
- `ChessNotationTests/ExpandedSquareRecognitionViewModelTests.swift`: CN-SPEC-0025-AC003, AC004, AC010, AC011, AC016, AC019, AC020, AC021.
- `ChessNotationTests/SquareRecognitionIntegrationTests.swift`: CN-SPEC-0025-AC003, AC004, AC011, AC014, AC016.
- `ChessNotationTests/PositionRecallGameTests.swift`: CN-SPEC-0025-AC005, AC006, AC008, AC009, AC010, AC014, AC017, AC018, AC023.
- `ChessNotationTests/PositionRecallReconstructionViewModelTests.swift`: CN-SPEC-0025-AC005, AC007, AC008, AC010, AC018, AC019, AC020, AC021, AC022.
- `ChessNotationTests/MiniGameLifecycleTests.swift`: CN-SPEC-0025-AC015 through AC023.
- `ChessNotationTests/PieceMovementFeatureTests.swift`: CN-SPEC-0025-AC012.
- `ChessNotationUITests/SANBuilderUITests.swift`: CN-SPEC-0025-AC001, AC002, AC013, AC015, AC019, AC020, AC021, AC022.
- `ChessNotationUITests/SquareRecognitionUITests.swift`: CN-SPEC-0025-AC003, AC004, AC013, AC016, AC019, AC020, AC021.
- `ChessNotationUITests/PositionRecallUITests.swift`: CN-SPEC-0025-AC005, AC006, AC008, AC013, AC017, AC018, AC019, AC020, AC021, AC022.
- Planned source owners: SAN Builder feature view/view model/history adapter; existing Square Recognition integration; existing Position Recall feature/domain; game-specific result views; lifecycle states in feature view models; catalog route resolver.

## Implementation Sequence

1. Add failing quick-start regression tests for current Square Recognition, Position Recall, and Piece Movement.
2. Add failing final-prompt, result-action, replay-reset, active-exit, and mid-session-generation-failure tests.
3. Complete SAN Builder feature-level view model and deterministic integration tests around existing domain logic.
4. Add setup intent mappers for Square Recognition and Position Recall.
5. Complete a real terminal result state for each game before exposing its production route.
6. Replace fixed direct construction with compatible quick-start presets resolved by the app layer.
7. Add production routes and UI tests one game at a time.
8. Add compatibility defaults only where persisted schemas change.
9. Run full mini-game, asset, accessibility, lifecycle, and home navigation suites before changing catalog ordering.

## Open Questions

- Whether SAN Builder deserves its own tile or appears as a notation-focused mini-game under a secondary catalog section. The decision should be based on discoverability and catalog density, not engine ownership.
- Whether bundled-game positions are sufficiently indexed for all recall intents without additional cached preprocessing. Any preprocessing must reuse CN-SPEC-0015 challenge/index boundaries.
- Whether abandoned mini-games save partial progress. The choice may differ by game, but it must be explicit and tested before implementation.

## Revision Notes

- 2026-07-10: Initial proposed spec for SAN Builder, expanded Square Recognition, and broader Position Recall recovery.
- 2026-07-10: Defined complete mini-game loops, authoritative endings, result metrics/actions, replay reset, safe interruption, mid-session failure handling, and anti-stuck acceptance criteria.