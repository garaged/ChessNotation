# CN-SPEC-0020: Notation Concept Games

Status: Accepted
Owner: Project
Last updated: 2026-07-08

## Intent

Add two complementary mini-games—SAN Builder and Position Recall—that teach notation structure and board visualization through interactions distinct from free-text move entry.

## Scope

In scope:

- SAN Builder component selection for piece, disambiguation, capture, destination, promotion, and check/checkmate suffix.
- Position Recall questions for piece location, square occupant, occupied-square subsets, and bounded reconstruction after a study period.
- Difficulty, scoring, prompt generation, history, accessibility, and performance constraints for both games.

Out of scope:

- Full legal-position validation, checkmate/stalemate detection, engine analysis, or best-move tactics.
- Runtime engine analysis or deriving best moves.
- Accepting SAN that cannot be validated against a trusted expected move.
- Testing complete legal chess positions beyond bundled/validated source data.

## Functional Requirements

- CN-SPEC-0020-FR001: SAN Builder must derive an ordered component model from the trusted expected SAN while preserving the app's accepted normalization rules.
- CN-SPEC-0020-FR002: Supported components must include pawn/piece designator, required file/rank disambiguation, capture marker, destination, promotion, castling form, and check/checkmate suffix where present.
- CN-SPEC-0020-FR003: The builder must offer only syntactically valid choices for the current component category while still including plausible distractors appropriate to difficulty.
- CN-SPEC-0020-FR004: The assembled answer must be validated through the shared SAN validation boundary rather than by UI string comparison alone.
- CN-SPEC-0020-FR005: Difficulty must progress from simple pawn and piece moves to captures, castling, checks, promotion, and disambiguation.
- CN-SPEC-0020-FR006: Feedback must identify the incorrect component category without revealing unresolved later components unless the challenge is finished or explicitly revealed.
- CN-SPEC-0020-FR007: Position Recall must display a validated position for a configured bounded study duration, then hide all or the relevant subset of pieces before asking a question.
- CN-SPEC-0020-FR008: Initial recall question kinds must include locating a named piece, naming the occupant of a square, selecting occupied squares within a bounded region or subset, and reconstructing bounded hidden pieces.
- CN-SPEC-0020-FR009: Recall prompts must have one unambiguous expected answer or expected set and must exclude positions that cannot satisfy that requirement.
- CN-SPEC-0020-FR010: Study timing must use an injected clock and transition exactly once even if UI callbacks are delayed.
- CN-SPEC-0020-FR011: The hidden-answer state must not leave piece accessibility labels, hit targets, debug text, or overlays that expose the memorized position.
- CN-SPEC-0020-FR012: Prompt generation and answer derivation must occur before presentation and outside SwiftUI view bodies.
- CN-SPEC-0020-FR013: Study duration, subset size, distractor count, question complexity, and orientation must be controlled by difficulty.
- CN-SPEC-0020-FR014: Both games must use bounded lazy generation, avoid immediate duplicates where possible, and recover from insufficient eligible source material.
- CN-SPEC-0020-FR015: Results must preserve game kind, difficulty, prompt categories, correctness, first-try/component mistakes or recall errors, latency, study duration, orientation, and finish reason.
- CN-SPEC-0020-FR016: VoiceOver must support component construction and recall responses while ensuring hidden position information is not announced after study ends.
- CN-SPEC-0020-FR017: Existing board, piece, FEN parsing, SAN normalization, settings, and history behavior must remain compatible.

## Acceptance Criteria

- CN-SPEC-0020-AC001: Given representative SAN fixtures for simple moves, captures, castling, promotion, disambiguation, check, and mate, when decomposed and reassembled correctly, then shared SAN validation accepts the result.
- CN-SPEC-0020-AC002: Given a SAN move requiring file or rank disambiguation, when the player omits or chooses the wrong component, then feedback identifies disambiguation without revealing the complete answer.
- CN-SPEC-0020-AC003: Given a correct component sequence, when submitted, then the challenge resolves correct and records no component mistakes.
- CN-SPEC-0020-AC004: Given an invalid component combination, when submitted, then it cannot bypass shared SAN validation.
- CN-SPEC-0020-AC005: Given beginner difficulty, when SAN Builder challenges are generated, then advanced-only categories are excluded according to documented rules.
- CN-SPEC-0020-AC006: Given a recall fixture and deterministic clock, when the study deadline passes despite delayed UI refresh, then pieces hide exactly once and the question becomes answerable.
- CN-SPEC-0020-AC007: Given the hidden phase, when the accessibility tree and visible hierarchy are inspected, then concealed pieces and answers are not exposed.
- CN-SPEC-0020-AC008: Given a locate-piece question, when a unique requested piece exists, then its square is the only accepted answer.
- CN-SPEC-0020-AC009: Given an occupant question, when the requested square is empty or occupied, then the corresponding explicit answer is accepted and distractors are rejected.
- CN-SPEC-0020-AC010: Given an occupied-subset or reconstruction question, when the exact expected set is selected, then order does not affect correctness and extra/missing squares or pieces are recorded separately.
- CN-SPEC-0020-AC011: Given a source position with ambiguous requested pieces or duplicate occupied squares, when generating a unique recall prompt, then it is excluded or a disambiguated piece description is used.
- CN-SPEC-0020-AC012: Given filters produce insufficient prompts, when either game starts, then it recovers with a documented fallback or clear configuration state rather than hanging.
- CN-SPEC-0020-AC013: Given completed SAN Builder and Position Recall sessions, when history is saved and restored, then all game-specific configuration and metrics are preserved.
- CN-SPEC-0020-AC014: Given VoiceOver, when using SAN Builder or transitioning from study to hidden recall, then controls remain usable and concealed position data is not announced.
- CN-SPEC-0020-AC015: Given repeated recall prompts from cached source positions, when a long session runs, then generation terminates within documented bounds and retained memory remains bounded.

## Coverage

- `ChessNotationTests/NotationConceptGameTests.swift`: CN-SPEC-0020-AC001, CN-SPEC-0020-AC002, CN-SPEC-0020-AC003, CN-SPEC-0020-AC004, CN-SPEC-0020-AC008, CN-SPEC-0020-AC009, CN-SPEC-0020-AC010, CN-SPEC-0020-AC013
- `ChessNotationTests/NotationConceptSessionTests.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC010, CN-SPEC-0020-AC013, CN-SPEC-0020-AC014
- `ChessNotationTests/NotationTrainingVarietyTests.swift`: CN-SPEC-0020-AC005, CN-SPEC-0020-AC012, CN-SPEC-0020-AC014, CN-SPEC-0020-AC015
- `ChessNotationTests/PositionRecallGameTests.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC010, CN-SPEC-0020-AC011, CN-SPEC-0020-AC013, CN-SPEC-0020-AC014, CN-SPEC-0020-AC015
- `ChessNotationTests/PositionRecallReconstructionSessionTests.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC010, CN-SPEC-0020-AC013, CN-SPEC-0020-AC014
- `ChessNotationTests/PositionRecallReconstructionViewModelTests.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC010, CN-SPEC-0020-AC014
- `ChessNotation/Domain/SANBuilderGame.swift`: CN-SPEC-0020-AC001, CN-SPEC-0020-AC002, CN-SPEC-0020-AC003, CN-SPEC-0020-AC004
- `ChessNotation/Domain/PositionRecallModels.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC008, CN-SPEC-0020-AC009, CN-SPEC-0020-AC010, CN-SPEC-0020-AC013, CN-SPEC-0020-AC014
- `ChessNotation/Domain/PositionRecallSession.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC014
- `ChessNotation/Domain/PositionRecallGame.swift`: CN-SPEC-0020-AC010, CN-SPEC-0020-AC011, CN-SPEC-0020-AC013, CN-SPEC-0020-AC014, CN-SPEC-0020-AC015
- `ChessNotation/Domain/PositionRecallReconstructionSession.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC010, CN-SPEC-0020-AC013, CN-SPEC-0020-AC014
- `ChessNotation/Features/PositionRecall/PositionRecallReconstructionHistoryStore.swift`: CN-SPEC-0020-AC013
- `ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift`: CN-SPEC-0020-AC006, CN-SPEC-0020-AC007, CN-SPEC-0020-AC010, CN-SPEC-0020-AC014

## Open Questions

- None. Complete chess legality and engine-derived tactics remain out of scope.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR6.
- 2026-07-08: Added SAN Builder and targeted Position Recall foundation coverage.
- 2026-07-08: Added reconstruction-domain prompt generation, duplicate-square rejection, bounded masking, order-independent evaluation, textual feedback, and result coverage.
- 2026-07-08: Added reconstruction session lifecycle, injected-clock study transitions, scoring, history, and `NotationConceptResult` conversion.
- 2026-07-08: Added production-facing reconstruction SwiftUI/view-model support with hidden-answer VoiceOver protection and black-orientation mapping coverage.
- 2026-07-08: Accepted after corrective simulator validation passed for concept, reconstruction domain, session, UI view-model, and notation variety suites.