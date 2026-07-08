# CN-SPEC-0018: Square Recognition Variety

Status: Accepted
Owner: Project
Last updated: 2026-07-07

## Intent

Expand square recognition from one repeated coordinate-to-tap loop into complementary drills that build coordinate recall, board orientation, square color knowledge, relative movement, and short spatial sequences.

## Scope

In scope:

- Find-the-square, name-the-square, square-color, relative-square, route, orientation, and restricted-zone drills.
- Bonus and strict timing variants where compatible.
- Shuffled-bag prompt coverage, board orientation rules, scoring, history migration, and accessibility.

Out of scope:

- Piece movement rules owned by CN-SPEC-0019.
- Full position memorization owned by CN-SPEC-0020.
- Online competition or remote content.

## Functional Requirements

- CN-SPEC-0018-FR001: Existing find-the-square behavior must remain available with current bonus and strict scoring semantics unless this spec explicitly refines timing authority.
- CN-SPEC-0018-FR002: Name-the-square must highlight one board square and accept a coordinate answer through an accessible input suited to the current device.
- CN-SPEC-0018-FR003: Square-color must ask whether a valid coordinate is light or dark and derive the answer from board geometry rather than a hard-coded lookup table.
- CN-SPEC-0018-FR004: Relative-square prompts must use bounded file/rank or diagonal offsets that resolve to exactly one valid destination square.
- CN-SPEC-0018-FR005: Route prompts must present an ordered sequence and require taps in the same order, with sequence length controlled by difficulty.
- CN-SPEC-0018-FR006: Sessions must support fixed white orientation, fixed black orientation, and alternating orientation, with orientation clearly visible and announced.
- CN-SPEC-0018-FR007: Restricted zones must support center, corners, edges, files, ranks, and quadrants where the resulting eligible set is non-empty.
- CN-SPEC-0018-FR008: Eligible square prompts must use shuffled-bag behavior so every eligible square is visited before repetition, except for route composition constraints.
- CN-SPEC-0018-FR009: A new prompt must not equal the immediately previous target when another eligible target exists.
- CN-SPEC-0018-FR010: Input must be blocked during correctness feedback or route-resolution transitions to prevent duplicate scoring.
- CN-SPEC-0018-FR011: Scoring must use captured answer timestamps and must remain independent from visual feedback delay.
- CN-SPEC-0018-FR012: Prompt generation, square-color calculation, offsets, route validation, and scoring must be pure/testable outside SwiftUI.
- CN-SPEC-0018-FR013: Results and history must preserve drill kind, orientation policy, zone, difficulty, timing variant, score, accuracy, latency, and route-specific metrics where applicable.
- CN-SPEC-0018-FR014: Existing square-recognition history without new fields must remain readable with legacy find-the-square defaults.
- CN-SPEC-0018-FR015: VoiceOver must identify squares according to visible orientation, announce the task and progress, and provide non-color-only feedback.
- CN-SPEC-0018-FR016: Board updates must avoid reparsing unrelated chess positions or rebuilding the complete board model when only prompt state changes.

## Acceptance Criteria

- CN-SPEC-0018-AC001: Given legacy find-the-square bonus and strict fixtures, when answered at fixed timestamps, then their existing time and score outcomes remain unchanged.
- CN-SPEC-0018-AC002: Given name-the-square and a highlighted e4, when `e4` is entered, then the answer is correct; another coordinate is incorrect.
- CN-SPEC-0018-AC003: Given every board coordinate, when square color is calculated, then adjacent orthogonal squares alternate color and known corner colors are correct.
- CN-SPEC-0018-AC004: Given a relative prompt whose requested offset would leave the board, when prompts are generated, then that invalid prompt is excluded rather than clamped or crashed.
- CN-SPEC-0018-AC005: Given a three-square route, when taps match the order, then one correct route is recorded; when order differs, then the route follows the documented incorrect-resolution rule.
- CN-SPEC-0018-AC006: Given black orientation, when a coordinate is prompted or selected, then visual placement, tap mapping, and accessibility labels still refer to the same chess coordinate.
- CN-SPEC-0018-AC007: Given a center-only zone, when one full shuffled cycle is generated, then every eligible center square appears exactly once and no outside square appears.
- CN-SPEC-0018-AC008: Given feedback is active, when extra taps occur, then only the first accepted input affects score and history.
- CN-SPEC-0018-AC009: Given identical prompt and answer timestamps but different visual feedback delays, when scored, then remaining time and score are identical.
- CN-SPEC-0018-AC010: Given zero eligible squares due to an invalid restored configuration, when the session opens, then it recovers to a documented safe default or configuration error state without crashing.
- CN-SPEC-0018-AC011: Given a completed session, when saved and restored, then drill kind, orientation, zone, difficulty, timing, and metrics are preserved.
- CN-SPEC-0018-AC012: Given legacy history JSON, when loaded, then records appear as find-the-square sessions with original metrics.
- CN-SPEC-0018-AC013: Given VoiceOver and black orientation, when the user explores and answers, then square labels, task, feedback, and progress are understandable without color alone.
- CN-SPEC-0018-AC014: Given a long session, when prompts change, then retained memory remains bounded and unchanged board resources are reused.

## Coverage

- `ChessNotationTests/SquareRecognitionVarietyTests.swift`: CN-SPEC-0018-AC002, CN-SPEC-0018-AC003, CN-SPEC-0018-AC004, CN-SPEC-0018-AC005, CN-SPEC-0018-AC007, CN-SPEC-0018-AC010, CN-SPEC-0018-AC011, CN-SPEC-0018-AC013, CN-SPEC-0018-AC014
- `ChessNotationTests/SquareRecognitionSessionTests.swift`: CN-SPEC-0018-AC002, CN-SPEC-0018-AC003, CN-SPEC-0018-AC005, CN-SPEC-0018-AC006, CN-SPEC-0018-AC008, CN-SPEC-0018-AC009, CN-SPEC-0018-AC010, CN-SPEC-0018-AC011
- `ChessNotationTests/SquareRecognitionIntegrationTests.swift`: CN-SPEC-0018-AC001, CN-SPEC-0018-AC012, CN-SPEC-0018-AC013, CN-SPEC-0018-AC014
- `ChessNotationTests/ExpandedSquareRecognitionViewModelTests.swift`: CN-SPEC-0018-AC002, CN-SPEC-0018-AC003, CN-SPEC-0018-AC005, CN-SPEC-0018-AC006, CN-SPEC-0018-AC008, CN-SPEC-0018-AC013
- `ChessNotation/Domain/SquareRecognitionDrills.swift`: CN-SPEC-0018-AC003, CN-SPEC-0018-AC004, CN-SPEC-0018-AC005, CN-SPEC-0018-AC007, CN-SPEC-0018-AC014
- `ChessNotation/Domain/SquareRecognitionSession.swift`: CN-SPEC-0018-AC002, CN-SPEC-0018-AC005, CN-SPEC-0018-AC006, CN-SPEC-0018-AC008, CN-SPEC-0018-AC009, CN-SPEC-0018-AC010, CN-SPEC-0018-AC011
- `ChessNotation/Features/SquareRecognition/SquareRecognitionIntegration.swift`: CN-SPEC-0018-AC001, CN-SPEC-0018-AC012, CN-SPEC-0018-AC013, CN-SPEC-0018-AC014
- `ChessNotation/Features/SquareRecognition/ExpandedSquareRecognitionView.swift`: CN-SPEC-0018-AC002, CN-SPEC-0018-AC005, CN-SPEC-0018-AC006, CN-SPEC-0018-AC008, CN-SPEC-0018-AC013

## Open Questions

- None. Exact route lengths and zone coordinate sets are explicit tested constants.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR4.
- 2026-07-07: Added square-recognition domain geometry, shuffled-bag generation, session evaluation, black-orientation mapping, persistence, migration, accessibility, and board-resource reuse coverage.
- 2026-07-07: Added production-facing expanded SwiftUI/view-model support for all five drills.
- 2026-07-07: Accepted after corrective simulator validation passed for variety, session, integration, and expanded view-model suites.