# CN-SPEC-0008: Board Coordinate Display

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

Players should be able to optionally show board coordinates while playing timed
games. When shown, coordinates should use the classic chess-board style so they
help orientation without competing with pieces, prompts, timers, or feedback.

## Scope

In scope:

- A reusable board coordinate display option.
- Applying the option to every timed game board.
- Classic in-board file and rank labels.
- Persisting the player's coordinate-display preference.
- Keeping square selection usable when coordinates are shown.

Out of scope:

- Coordinates outside the board frame.
- Per-game coordinate styling.
- Algebraic move notation changes.
- Requiring untimed training games to show coordinates.

## Functional Requirements

- CN-SPEC-0008-FR001: The app must provide a player-configurable setting for showing board coordinates.
- CN-SPEC-0008-FR002: The coordinate-display setting must persist across app launches.
- CN-SPEC-0008-FR003: Every timed game board must use the shared coordinate-display setting.
- CN-SPEC-0008-FR004: When coordinates are enabled, the board must show files `a` through `h` and ranks `1` through `8`.
- CN-SPEC-0008-FR005: Coordinates must use classic chess style: file labels inside the bottom edge of the board and rank labels inside the left edge of the board.
- CN-SPEC-0008-FR006: Coordinate labels must be drawn inside their corresponding squares and must not change board size.
- CN-SPEC-0008-FR007: Coordinate labels must not intercept square taps or clicks.
- CN-SPEC-0008-FR008: Coordinate labels must remain legible on both light and dark squares.
- CN-SPEC-0008-FR009: When coordinates are disabled, no coordinate labels must be rendered.
- CN-SPEC-0008-FR010: Untimed training games may adopt the same shared board option, but timed games are the required integration target.

## Acceptance Criteria

- CN-SPEC-0008-AC001: Given coordinate display is enabled, when a timed notation game board appears, then file labels `a` through `h` and rank labels `1` through `8` are visible in classic in-board positions.
- CN-SPEC-0008-AC002: Given coordinate display is enabled, when a timed square-recognition board appears, then file labels `a` through `h` and rank labels `1` through `8` are visible in classic in-board positions.
- CN-SPEC-0008-AC003: Given coordinate display is disabled, when any timed game board appears, then no coordinate labels are visible.
- CN-SPEC-0008-AC004: Given the player changes the coordinate-display setting, when the app is relaunched, then the last selected value is restored.
- CN-SPEC-0008-AC005: Given coordinates are shown, when the player taps or clicks a square in a timed square-recognition game, then the square receives the input even if the tap lands on a coordinate label.
- CN-SPEC-0008-AC006: Given coordinates are shown on a narrow device, when the board renders, then labels do not resize the board or overlap timer, prompt, answer, or feedback controls.
- CN-SPEC-0008-AC007: Given coordinates are shown with any board theme, when light and dark squares render, then labels remain legible.

## Coverage

- `ChessNotationTests/NotationServicesTests.swift`: CN-SPEC-0008-AC004
- `ChessNotation/App/AppSettings.swift`: CN-SPEC-0008-AC004
- `ChessNotation/Features/Game/ChessBoardView.swift`: CN-SPEC-0008-AC001, CN-SPEC-0008-AC003, CN-SPEC-0008-AC006, CN-SPEC-0008-AC007
- `ChessNotation/Features/Game/GameTrainingView.swift`: CN-SPEC-0008-AC001, CN-SPEC-0008-AC003, CN-SPEC-0008-AC006
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViews.swift`: CN-SPEC-0008-AC002, CN-SPEC-0008-AC003, CN-SPEC-0008-AC005, CN-SPEC-0008-AC006, CN-SPEC-0008-AC007

## Open Questions

- Resolved: Untimed training adopts the same shared coordinate setting.
- Resolved: Orientation changes are deferred; current coordinate placement follows White's perspective.

## Revision Notes

- 2026-06-27: Initial proposed spec for optional classic board coordinates in timed games.
- 2026-06-28: Accepted after implementation and coverage audit.
