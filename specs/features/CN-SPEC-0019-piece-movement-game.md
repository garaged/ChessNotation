# CN-SPEC-0019: Piece Movement Game

Status: Accepted
Owner: Project
Last updated: 2026-07-07

## Intent

Add a distinct board-visualization mini-game that teaches geometric movement, blockers, and captures for every chess piece without prematurely introducing a full chess-legality engine.

## Scope

In scope:

- Empty-board movement for king, queen, rook, bishop, knight, and pawn.
- Friendly blockers, enemy occupancy, capture destinations, orientation, difficulty, scoring, and history.
- Pure movement geometry and occupancy rules with exhaustive edge/corner tests.

Out of scope:

- Check, pins, discovered attacks, legal-position validation, castling, en passant, promotion choice, or move legality relative to kings.
- Runtime engine analysis or tactical best moves.
- Drag-and-drop piece movement.

## Functional Requirements

- CN-SPEC-0019-FR001: A prompt must define board orientation, side to move, one training piece, its source square, occupied squares, expected legal geometric destinations, and difficulty.
- CN-SPEC-0019-FR002: Sliding pieces must continue along each valid ray until the board edge or first occupied square.
- CN-SPEC-0019-FR003: A friendly occupied square must block its ray and must not be selectable; an enemy occupied square must be selectable as a capture and block squares beyond it.
- CN-SPEC-0019-FR004: Knight and king destinations must be bounded to the board and exclude friendly occupied squares.
- CN-SPEC-0019-FR005: Pawns must use side-relative forward direction, single forward movement only when empty, optional initial double movement only under an explicitly enabled rule, and diagonal captures only onto enemy occupancy.
- CN-SPEC-0019-FR006: The first release must not ask whether a destination leaves a king in check and must clearly describe the mode as movement geometry rather than complete legal-move training.
- CN-SPEC-0019-FR007: Players must select all expected destinations and submit, or the configured interaction may auto-resolve only when correctness can be determined without ambiguity.
- CN-SPEC-0019-FR008: Feedback must distinguish missing legal destinations, extra illegal destinations, and correct completion without relying only on color.
- CN-SPEC-0019-FR009: Difficulty must progress from empty boards to blockers and captures, larger destination sets, mixed piece types, and alternating orientation.
- CN-SPEC-0019-FR010: Prompt generation must guarantee at least one expected destination unless a deliberate zero-move lesson is separately identified and explained.
- CN-SPEC-0019-FR011: Geometry, occupancy, prompt generation, validation, and scoring must be pure and testable outside SwiftUI.
- CN-SPEC-0019-FR012: Generation must be bounded, avoid immediate duplicate piece/source/occupancy combinations where alternatives exist, and use CN-SPEC-0015 randomness.
- CN-SPEC-0019-FR013: Results must preserve piece type, difficulty, orientation, prompt count, exact/partial correctness, missing and extra selections, latency, streak, and finish reason.
- CN-SPEC-0019-FR014: VoiceOver must identify the training piece, source, occupied-square relationship, selectable squares, current selections, feedback, and progress.
- CN-SPEC-0019-FR015: Board rendering must reuse existing lightweight board components and must not require new network, engine, or large asset dependencies.
- CN-SPEC-0019-FR016: Home must present Piece Movement as an image-based premium mini-game tile using `TilePieceMovement`, preserve `home.pieceMovementLink`, and avoid generic chess glyph or symbol overlays when production artwork is available.

## Acceptance Criteria

- CN-SPEC-0019-AC001: Given each piece on representative center, edge, and corner squares on an empty board, when destinations are calculated, then the result matches chess movement geometry within board bounds.
- CN-SPEC-0019-AC002: Given a sliding piece with a friendly blocker, when destinations are calculated, then the blocker and every square beyond it on that ray are excluded.
- CN-SPEC-0019-AC003: Given a sliding piece with an enemy blocker, when destinations are calculated, then the enemy square is included and every square beyond it is excluded.
- CN-SPEC-0019-AC004: Given knight or king candidates occupied by friendly and enemy pieces, when destinations are calculated, then friendly squares are excluded and enemy squares are included.
- CN-SPEC-0019-AC005: Given white and black pawns in equivalent mirrored positions, when movement is calculated, then forward and capture directions mirror correctly.
- CN-SPEC-0019-AC006: Given a pawn's forward square is occupied, when destinations are calculated, then forward movement and any dependent double movement are excluded.
- CN-SPEC-0019-AC007: Given a generated normal prompt, when inspected, then it has at least one expected destination and contains no overlapping friendly/enemy occupancy.
- CN-SPEC-0019-AC008: Given the player selects exactly the expected set, when submitted, then the prompt is correct regardless of selection order.
- CN-SPEC-0019-AC009: Given missing and extra selections, when submitted, then both categories are recorded and communicated without color-only feedback.
- CN-SPEC-0019-AC010: Given black orientation, when squares are displayed and tapped, then coordinate mapping and validation remain correct.
- CN-SPEC-0019-AC011: Given a completed session is saved and restored, then its configuration and movement-specific metrics are preserved.
- CN-SPEC-0019-AC012: Given VoiceOver, when the player explores and submits a prompt, then piece, source, occupancy, selection state, feedback, and progress are understandable.
- CN-SPEC-0019-AC013: Given one thousand generated prompts from representative fixtures, when generation is measured, then it terminates within documented bounds, avoids invalid states, and retains bounded memory.
- CN-SPEC-0019-AC014: Given Home is displayed, when the Piece Movement tile is inspected and selected, then it uses the production `TilePieceMovement` artwork, keeps its accessibility entry point, and opens the Piece Movement game.

## Coverage

- `ChessNotationTests/PieceMovementGameTests.swift`: CN-SPEC-0019-AC001, CN-SPEC-0019-AC002, CN-SPEC-0019-AC003, CN-SPEC-0019-AC004, CN-SPEC-0019-AC005, CN-SPEC-0019-AC006, CN-SPEC-0019-AC008, CN-SPEC-0019-AC009, CN-SPEC-0019-AC012
- `ChessNotationTests/PieceMovementSessionTests.swift`: CN-SPEC-0019-AC007, CN-SPEC-0019-AC008, CN-SPEC-0019-AC009, CN-SPEC-0019-AC010, CN-SPEC-0019-AC011, CN-SPEC-0019-AC013
- `ChessNotationTests/PieceMovementFeatureTests.swift`: CN-SPEC-0019-AC009, CN-SPEC-0019-AC011, CN-SPEC-0019-AC012
- `ChessNotation/Domain/PieceMovementGame.swift`: CN-SPEC-0019-AC001, CN-SPEC-0019-AC002, CN-SPEC-0019-AC003, CN-SPEC-0019-AC004, CN-SPEC-0019-AC005, CN-SPEC-0019-AC006, CN-SPEC-0019-AC008, CN-SPEC-0019-AC009, CN-SPEC-0019-AC012
- `ChessNotation/Domain/PieceMovementSession.swift`: CN-SPEC-0019-AC007, CN-SPEC-0019-AC008, CN-SPEC-0019-AC009, CN-SPEC-0019-AC010, CN-SPEC-0019-AC011, CN-SPEC-0019-AC013
- `ChessNotation/Features/PieceMovement/PieceMovementFeature.swift`: CN-SPEC-0019-AC009, CN-SPEC-0019-AC010, CN-SPEC-0019-AC011, CN-SPEC-0019-AC012
- `ChessNotation/Features/Home/RestoredHomeView.swift`: CN-SPEC-0019-AC014
- `ChessNotationTests/PremiumAssetTests.swift`: CN-SPEC-0019-AC014
- `ChessNotationUITests/HomeUITests.swift`: CN-SPEC-0019-AC014

## Open Questions

- None. Initial pawn double-step support must be explicitly enabled by difficulty/configuration and is not implied by default.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR5.
- 2026-07-08: Added deterministic generation, mixed-piece/difficulty/orientation policies, session lifecycle, exact/partial scoring, latency/streak metrics, and bounded-generation coverage.
- 2026-07-08: Added production-facing SwiftUI board interaction, history persistence, textual feedback, VoiceOver summaries, and result save flow.
- 2026-07-08: Accepted after corrective simulator validation passed for movement geometry, session, and feature suites.
- 2026-07-10: Added production Home tile artwork and navigation coverage.
