# CN-SPEC-0025: SAN Builder and Expanded Mini-game Recovery

Status: Proposed
Owner: Project
Last updated: 2026-07-10

## Intent

Complete and expose the mini-game experiences that are already supported by current domain and feature foundations: SAN Builder, expanded Square Recognition drills, and the broader Position Recall family. Keep the same quiet, premium training feel as current mini-games, preserve current defaults, and reuse shared chess, timing, board, history, and challenge engines.

## Scope

In scope:

- A production SAN Builder setup, session, result, and history flow.
- Expanded Square Recognition variants integrated under the current Square Recognition identity.
- Position Recall setup for locate-piece, square-occupant, occupied-subset, and reconstruction questions.
- Existing Piece Movement and current Position Recall reconstruction as regression anchors.
- Shared mini-game setup conventions where repeated, stable behavior justifies them.
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

Each intent must map to a game-specific typed configuration. Shared setup abstractions may cover only stable concepts such as difficulty, orientation, prompt limit, random source, clock, and history destination.

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
- CN-SPEC-0025-FR013: Existing Piece Movement scoring, geometry, beginner preset, history, and navigation must remain unchanged.
- CN-SPEC-0025-FR014: Existing Square Recognition and Position Recall history must remain readable; new fields require defaults and compatibility tests.
- CN-SPEC-0025-FR015: UI and view models must expose loading, study, answering, feedback, completion, unavailable, and exit states explicitly where applicable.
- CN-SPEC-0025-FR016: Views must reuse current board components, `PremiumDesign`, tile art/fallbacks, reduced-motion behavior, haptic settings, and accessibility conventions.
- CN-SPEC-0025-FR017: A shared mini-game abstraction may be introduced only after at least two recovered games demonstrate identical lifecycle or setup behavior; scoring and answer evaluation remain game-specific.
- CN-SPEC-0025-FR018: Current mini-game UI tests must continue to pass, and each recovered intent must add at least one deterministic unit/integration test plus one representative navigation UI test.

## Acceptance Criteria

- CN-SPEC-0025-AC001: Given representative SAN fixtures, when SAN Builder components are selected correctly, then shared SAN validation accepts the assembled answer and the result records no component mistakes.
- CN-SPEC-0025-AC002: Given an incorrect SAN component, when feedback is shown, then the incorrect category is identified without revealing unresolved components or the complete SAN.
- CN-SPEC-0025-AC003: Given the existing Square Recognition quick-start preset, when launched after recovery, then current coordinate-tap rules, orientation, scoring, history, and identifiers remain unchanged.
- CN-SPEC-0025-AC004: Given each expanded square-recognition intent and deterministic prompts, when a session runs, then scoring and result metadata follow existing square-recognition domain rules.
- CN-SPEC-0025-AC005: Given the existing Position Recall quick-start preset, when launched after recovery, then the current beginner reconstruction configuration remains equivalent.
- CN-SPEC-0025-AC006: Given locate-piece, occupant, occupied-subset, and reconstruction intents, when eligible deterministic fixtures are used, then each produces one unambiguous expected answer or set.
- CN-SPEC-0025-AC007: Given a delayed study timer callback, when authoritative time passes the deadline, then the hidden phase begins exactly once through the existing injected-clock policy.
- CN-SPEC-0025-AC008: Given any hidden recall phase with VoiceOver enabled, when the accessibility hierarchy is inspected, then concealed answer data is absent while answer controls remain usable.
- CN-SPEC-0025-AC009: Given ambiguous, malformed, or insufficient source positions, when prompts are generated, then they are rejected within bounded work and setup offers a recoverable alternative.
- CN-SPEC-0025-AC010: Given completed recovered mini-games, when results are saved and restored, then stable identity, intent, configuration, metrics, and finish reason are preserved.
- CN-SPEC-0025-AC011: Given legacy Square Recognition and Position Recall records, when loaded after new fields are introduced, then existing data remains visible with documented defaults.
- CN-SPEC-0025-AC012: Given Piece Movement regression fixtures, when mini-game routing and any shared setup abstractions are introduced, then movement destinations, scoring, beginner preset, and history behavior remain unchanged.
- CN-SPEC-0025-AC013: Given compact and regular width devices, when recovered mini-games are used, then board interaction, component controls, feedback, and result layouts remain readable and preserve the current premium visual character.
- CN-SPEC-0025-AC014: Given long deterministic mini-game sessions, when prompt generation and history aggregation run, then memory and retained result data remain bounded and immediate duplicates are avoided where possible.

## Planned Coverage

- `ChessNotationTests/SANBuilderViewModelTests.swift`: CN-SPEC-0025-AC001, AC002, AC009, AC010.
- `ChessNotationTests/NotationConceptGameTests.swift`: CN-SPEC-0025-AC001, AC002, AC006, AC010, AC014.
- `ChessNotationTests/ExpandedSquareRecognitionViewModelTests.swift`: CN-SPEC-0025-AC003, AC004, AC010, AC011.
- `ChessNotationTests/SquareRecognitionIntegrationTests.swift`: CN-SPEC-0025-AC003, AC004, AC011, AC014.
- `ChessNotationTests/PositionRecallGameTests.swift`: CN-SPEC-0025-AC005, AC006, AC008, AC009, AC010, AC014.
- `ChessNotationTests/PositionRecallReconstructionViewModelTests.swift`: CN-SPEC-0025-AC005, AC007, AC008, AC010.
- `ChessNotationTests/PieceMovementFeatureTests.swift`: CN-SPEC-0025-AC012.
- `ChessNotationUITests/SANBuilderUITests.swift`: CN-SPEC-0025-AC001, AC002, AC013.
- `ChessNotationUITests/SquareRecognitionUITests.swift`: CN-SPEC-0025-AC003, AC004, AC013.
- `ChessNotationUITests/PositionRecallUITests.swift`: CN-SPEC-0025-AC005, AC006, AC008, AC013.
- Planned source owners: SAN Builder feature view/view model/history adapter; existing Square Recognition integration; existing Position Recall feature/domain; catalog route resolver.

## Implementation Sequence

1. Add failing quick-start regression tests for current Square Recognition, Position Recall, and Piece Movement.
2. Complete SAN Builder feature-level view model and deterministic integration tests around existing domain logic.
3. Add setup intent mappers for Square Recognition and Position Recall.
4. Replace fixed direct construction with compatible quick-start presets resolved by the app layer.
5. Add production routes and UI tests one game at a time.
6. Add compatibility defaults only where persisted schemas change.
7. Run full mini-game, asset, accessibility, and home navigation suites before changing catalog ordering.

## Open Questions

- Whether SAN Builder deserves its own tile or appears as a notation-focused mini-game under a secondary catalog section. The decision should be based on discoverability and catalog density, not engine ownership.
- Whether bundled-game positions are sufficiently indexed for all recall intents without additional cached preprocessing. Any preprocessing must reuse CN-SPEC-0015 challenge/index boundaries.

## Revision Notes

- 2026-07-10: Initial proposed spec for SAN Builder, expanded Square Recognition, and broader Position Recall recovery.
