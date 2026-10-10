# CN-SPEC-0028: Board Legibility and Piece Scale

Status: Proposed
Owner: Project
Last updated: 2026-10-10

## Intent

Make every chess position immediately readable on an iPhone. The board must preserve the app's calm, premium visual language while improving square separation, piece-side recognition, piece-type recognition, and perceived piece size. This is a rendering and interaction-legibility upgrade; it must not alter chess rules, game content, scores, timers, or training flow.

## Scope

In scope:

- A color-theory-led visual contract for the default board and the existing Marble, Wood, and Metal themes.
- A redesigned, transparent black-and-white chess-piece set with consistent silhouettes, contrast-recovery contours, and normalized optical scale.
- A shared iPhone-first piece-size policy for notation training, Piece Movement, Position Recall, board previews, and settings previews.
- Deterministic contrast, alpha-bounds, footprint, and theme-contract validation.
- Rendered iPhone and iPad verification, with iPhone results as the release gate.
- Preservation of coordinates, arrows, selection states, evaluation bar, Dynamic Type behavior, VoiceOver labels, and stable accessibility identifiers.

Out of scope:

- New gameplay modes, chess rules, scoring, timers, persistence, or navigation changes.
- A new board-theme picker, paid assets, analytics, or network activity.
- Replacing premium Home artwork or changing its visual direction.
- Replacing the player-selected theme without preserving its preference key and available options.

## Functional Requirements

- CN-SPEC-0028-FR001: The board renderer must centralize square colors, piece colors, outline colors, highlight colors, and piece-size tokens in one feature-level visual contract reused by every board surface.
- CN-SPEC-0028-FR002: Every shipped theme must provide light and dark square colors whose least-contrasting solid endpoints have a WCAG relative-luminance contrast ratio of at least 3:1.
- CN-SPEC-0028-FR003: For each theme and each square color, the visible boundary of every white and black piece must meet at least 3:1 contrast against that square; the contract must evaluate the least favorable adjacent color rather than only the preferred square color.
- CN-SPEC-0028-FR004: The white and black sets must be distinguishable by both luminance and non-color form cues: opposing fill, a contrasting contour where necessary, and stable, recognizably different silhouettes for king, queen, rook, bishop, knight, and pawn.
- CN-SPEC-0028-FR005: Production chess-piece assets must retain true transparency and must not include opaque rectangular backgrounds, text, logos, watermarks, or decorative board imagery.
- CN-SPEC-0028-FR006: On an iPhone board, each kind's visible alpha bounds must occupy a consistent optical footprint: pawn at least 80% of square height; knight, bishop, rook, queen, and king at least 86%; no kind may exceed 96% after its presentation inset.
- CN-SPEC-0028-FR007: The presentation frame for every piece kind must use a shared size policy rather than the existing per-view hard-coded 0.82, 0.74, 0.88, 0.90, 0.92, and 0.94 multipliers.
- CN-SPEC-0028-FR008: The piece-size policy must leave a minimum 2-point visual clearance to every square edge at the smallest supported board square, without clipping a shadow, contour, coordinate label, selected-state overlay, or move arrow.
- CN-SPEC-0028-FR009: Main-game boards must prioritize board width on compact iPhone layouts; when evaluation is shown, it may compress or relocate its bar only if the board remains square, centered, and the board-size policy is satisfied.
- CN-SPEC-0028-FR010: Coordinates, move arrows, source/selection overlays, friendly/enemy indicators, masked-position markers, and evaluation labels must have a documented contrast treatment that remains identifiable over either square color and either piece side.
- CN-SPEC-0028-FR011: Existing `ChessVisualTheme` persisted values, user-visible theme choices, board orientation, coordinates setting, evaluation setting, accessibility labels, and accessibility identifiers must remain compatible.
- CN-SPEC-0028-FR012: The redesign must honor Reduce Motion and Dynamic Type without making the board, training prompt, primary action, or results continuation unreachable.

## Acceptance Criteria

- CN-SPEC-0028-AC001: Given any shipped theme, when its board token matrix is validated, then light/dark square endpoints and every piece-boundary/square pairing meet the documented contrast thresholds.
- CN-SPEC-0028-AC002: Given all twelve production piece assets, when their alpha bounds are inspected, then each has true transparency, no opaque rectangular background, and a footprint within the documented kind-specific range.
- CN-SPEC-0028-AC003: Given a standard notation board on an iPhone 5.4-inch viewport, when white or black pieces occur on either square color, then each occupied square makes both piece side and piece kind readily distinguishable without changing the selected theme.
- CN-SPEC-0028-AC004: Given a compact iPhone notation-training screen with evaluation enabled, when the board is laid out, then the board remains square, centered, fully visible, and uses at least the documented compact-width allocation without overlap or clipped controls.
- CN-SPEC-0028-AC005: Given Piece Movement and Position Recall boards, when a source or reconstructed piece is rendered, then it uses the shared piece-size policy and remains distinguishable from state overlays and coordinate labels.
- CN-SPEC-0028-AC006: Given a settings theme preview or game thumbnail with pieces, when it is rendered, then it uses the same piece set and optical size policy as the gameplay board.
- CN-SPEC-0028-AC007: Given coordinates, arrows, evaluation labels, selected squares, source squares, friendly/enemy indicators, and masked markers, when displayed over every board theme, then each remains distinguishable without relying on color alone.
- CN-SPEC-0028-AC008: Given an existing stored visual-theme preference and the current accessibility/UI-test flows, when the redesign is installed, then the selected theme, all board settings, VoiceOver semantics, and stable identifiers continue to work unchanged.
- CN-SPEC-0028-AC009: Given the required rendered-device matrix, when the completed build is inspected on iPhone 5.4-inch, iPhone 6.7-inch, and iPad 11-inch viewports at normal and accessibility Dynamic Type sizes, then there is no board clipping, unwanted overlap, or unreachable primary action; the two iPhone renders are release gates.

## Coverage

- `docs/board-legibility-redesign-plan.md`: CN-SPEC-0028-AC001, CN-SPEC-0028-AC002, CN-SPEC-0028-AC003, CN-SPEC-0028-AC004, CN-SPEC-0028-AC005, CN-SPEC-0028-AC006, CN-SPEC-0028-AC007, CN-SPEC-0028-AC008, CN-SPEC-0028-AC009
- `ChessNotationTests/ChessBoardLegibilityTests.swift`: CN-SPEC-0028-AC001, CN-SPEC-0028-AC005, CN-SPEC-0028-AC006
- `ChessNotationTests/ChessPieceAssetAuditTests.swift`: CN-SPEC-0028-AC002, CN-SPEC-0028-AC003, CN-SPEC-0028-AC006
- `ChessNotation/Features/Game/ChessBoardLegibility.swift`: CN-SPEC-0028-AC001, CN-SPEC-0028-AC003, CN-SPEC-0028-AC005, CN-SPEC-0028-AC006, CN-SPEC-0028-AC007
- `ChessNotation/Features/Game/ChessTheme.swift`: CN-SPEC-0028-AC001, CN-SPEC-0028-AC003, CN-SPEC-0028-AC007
- `ChessNotation/Features/Game/ChessBoardView.swift`: CN-SPEC-0028-AC003, CN-SPEC-0028-AC004, CN-SPEC-0028-AC007
- `ChessNotation/Features/PieceMovement/PieceMovementFeature.swift`: CN-SPEC-0028-AC005, CN-SPEC-0028-AC008
- `ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift`: CN-SPEC-0028-AC005, CN-SPEC-0028-AC008
- `ChessNotation/Features/Home/AppearanceSettingsView.swift`: CN-SPEC-0028-AC006, CN-SPEC-0028-AC008
- `ChessNotation/Features/Home/GameThumbnailPreview.swift`: CN-SPEC-0028-AC006, CN-SPEC-0028-AC008
- Pending rendered-device coverage: `ChessNotationUITests/BoardLegibilityUITests.swift` for CN-SPEC-0028-AC004, CN-SPEC-0028-AC008, CN-SPEC-0028-AC009.

## Open Questions

- Resolved for implementation: retain the four existing persisted theme identifiers; improve them as a coherent family instead of replacing the selector with a new one.
- Resolved for implementation: use a custom transparent piece set with contrast-recovery contours, not Unicode glyphs or system chess symbols.
- Resolved for implementation: target iPhone first, with iPad verification required but not allowed to dilute compact-phone decisions.
- Deferred: a user-adjustable piece-size control. The initial redesign must establish a single accessible default before introducing personalization.

## Revision Notes

- 2026-10-10: Initial proposed contract derived from the current main-board audit. It replaces subjective visual approval with measurable contrast, asset, scale, and rendered-device gates.
