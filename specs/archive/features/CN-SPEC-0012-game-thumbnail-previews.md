# CN-SPEC-0012: Game Thumbnail Previews

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

Every game row in the redesigned Game Library should show a meaningful preview
of that particular game, not a generic board icon. The thumbnail should be
generated from each game's real move sequence after 5 to 10 plies, giving the
player a quick visual cue for the opening structure and making the library feel
specific and premium.

## Scope

In scope:

- Generating a board thumbnail for every bundled notation game.
- Applying 5 to 10 moves or plies from the particular game to produce the
  thumbnail position.
- Rendering thumbnails consistently with the premium library visual design.
- Storing or caching thumbnail metadata/assets in a stable way.
- Testing that thumbnails are game-specific and not generic placeholders.

Out of scope:

- Generating legal moves with a chess engine.
- Downloading thumbnails from remote services.
- Animated thumbnails.
- Manual illustration prompts for each game unless board-position rendering is
  technically blocked.

## Functional Requirements

- CN-SPEC-0012-FR001: The Game Library must show a thumbnail for each visible game row.
- CN-SPEC-0012-FR002: Each thumbnail must represent the specific game row it belongs to.
- CN-SPEC-0012-FR003: Thumbnail generation must use the bundled game's move sequence and must not use a single generic board image for all games.
- CN-SPEC-0012-FR004: The thumbnail position must be based on a move window after 5 to 10 plies when the game contains enough moves.
- CN-SPEC-0012-FR005: If a game has fewer than 5 plies, the thumbnail must use the final available position.
- CN-SPEC-0012-FR006: Thumbnail generation may use existing `fenBefore`, `from`, and `to` move data to advance a lightweight board state without requiring a chess engine.
- CN-SPEC-0012-FR007: Captures must remove the piece on the destination square in generated thumbnail positions.
- CN-SPEC-0012-FR008: Castling, promotion, and en passant thumbnails must be handled correctly or must fall back to a known valid `fenBefore` from the target move rather than producing an invalid board.
- CN-SPEC-0012-FR009: Thumbnail rendering must show recognizable pieces, board colors, and orientation from White's perspective.
- CN-SPEC-0012-FR010: Thumbnail rendering must be fast enough for the Game Library to scroll smoothly.
- CN-SPEC-0012-FR011: Thumbnails may be generated at runtime, cached in memory, or pre-rendered as assets, provided the position is derived from the game data.
- CN-SPEC-0012-FR012: Thumbnail visuals must match the premium redesign closely enough to sit beside rich library rows without looking like debug output.
- CN-SPEC-0012-FR013: Thumbnail accessibility labels must identify the preview as a board preview for the game title.
- CN-SPEC-0012-FR014: Thumbnail generation must expose debug or test metadata describing whether the thumbnail came from applied moves, short-game final position, or FEN fallback.
- CN-SPEC-0012-FR015: Unsupported or ambiguous SAN-special cases must never render a board known to be invalid; they must fall back to a valid bundled FEN.
- CN-SPEC-0012-FR016: The move applier must remove captured pieces on destination squares for regular captures before the thumbnail is rendered.

## Thumbnail Generation Rules

- Preferred preview ply: 8 plies.
- Minimum preview range: 5 plies when available.
- Maximum preview range: 10 plies.
- If a game has at least 8 plies, render the position after applying 8 plies.
- If a game has 5 to 7 plies, render the final available position.
- If a game has fewer than 5 plies, render the final available position and mark
  it as a short-game preview in tests or debug metadata.
- If the lightweight move applier cannot safely apply a move, render the
  `fenBefore` of the last successfully reached move.
- The generator must record the source of each thumbnail position for tests and
  debugging: `appliedMoves`, `shortGameFinalPosition`, or `fenFallback`.
- `appliedMoves` means the thumbnail was produced by applying coordinate moves
  from the start position or a known FEN.
- `shortGameFinalPosition` means the game had fewer than the preferred preview
  plies and the final available move was used.
- `fenFallback` means the generator stopped applying moves and used the nearest
  valid bundled FEN instead.

## Move Application Fallback Rules

The first implementation may use a lightweight coordinate-based move applier,
but it must fail safely.

- Regular moves: move the piece from `from` to `to`; remove any piece currently
  on `to`.
- Missing source piece: stop applying and use `fenFallback`.
- Invalid coordinates: stop applying and use `fenFallback`.
- Castling: if SAN or tags indicate castling and rook movement is not
  implemented, stop applying before the castling move and use `fenFallback`.
- Promotion: if promotion piece replacement is not implemented, stop applying
  before the promotion move and use `fenFallback`.
- En passant: if en passant capture removal is not implemented, stop applying
  before the en passant move and use `fenFallback`.
- Any unsupported special case must prefer a valid but earlier board preview
  over a visually incorrect board.
- Tests must cover at least one capture and at least one unsupported-special-case
  fallback path.

## Optional Fallback Image Prompt

Game-specific thumbnails should be board renders, not AI illustrations. Use this
prompt only if a temporary placeholder is required while the board renderer is
being implemented:

```text
Small premium chess game thumbnail, top-down view of a realistic chessboard
with pieces in an early opening position, dark app UI style, warm highlights,
high contrast, no text, no logo, no watermark. This is a temporary placeholder
and must be replaced by a thumbnail generated from the real game's move data.
```

## Acceptance Criteria

- CN-SPEC-0012-AC001: Given the Game Library loads bundled games, when rows are shown, then each row includes a board thumbnail preview.
- CN-SPEC-0012-AC002: Given two bundled games have different first 8 plies, when thumbnails are generated, then their thumbnail positions differ.
- CN-SPEC-0012-AC003: Given a bundled game has at least 8 plies, when its thumbnail is generated, then the rendered position reflects the board after 8 plies.
- CN-SPEC-0012-AC004: Given a bundled game has between 5 and 7 plies, when its thumbnail is generated, then the rendered position reflects the final available move.
- CN-SPEC-0012-AC005: Given a bundled game has fewer than 5 plies, when its thumbnail is generated, then the rendered position reflects the final available move and does not crash.
- CN-SPEC-0012-AC006: Given a thumbnail move includes a capture, when the thumbnail board is generated, then the captured piece is removed from the destination square.
- CN-SPEC-0012-AC007: Given a thumbnail move includes castling or promotion, when the move cannot be safely applied by lightweight logic, then the generator falls back to a valid bundled FEN rather than rendering an invalid board.
- CN-SPEC-0012-AC008: Given the Game Library scrolls, when thumbnails render, then row layout remains stable and scrolling remains usable.
- CN-SPEC-0012-AC009: Given VoiceOver focuses a game thumbnail, when the label is read, then it identifies the thumbnail as a board preview for that game.
- CN-SPEC-0012-AC010: Given a thumbnail is generated, when test metadata is inspected, then it reports `appliedMoves`, `shortGameFinalPosition`, or `fenFallback`.
- CN-SPEC-0012-AC011: Given an unsupported special move is encountered before the preview ply, when generation continues, then the thumbnail uses `fenFallback` metadata and a valid board.

## Coverage

- `ChessNotationTests/GameThumbnailPreviewTests.swift`: CN-SPEC-0012-AC002, CN-SPEC-0012-AC003, CN-SPEC-0012-AC004, CN-SPEC-0012-AC005, CN-SPEC-0012-AC006, CN-SPEC-0012-AC007, CN-SPEC-0012-AC010, CN-SPEC-0012-AC011
- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0012-AC001, CN-SPEC-0012-AC008, CN-SPEC-0012-AC009

## Open Questions

- Resolved: Thumbnails are generated at runtime for visible game rows.
- Resolved: Thumbnail previews use the shared premium board/piece presentation.
- Resolved: Preview ply is fixed at 8 for the first implementation.

## Revision Notes

- 2026-06-27: Initial proposed spec for game-specific board thumbnail previews.
- 2026-06-27: Added operational move-application fallback rules and thumbnail source metadata.
- 2026-06-28: Accepted after implementation and coverage audit.
