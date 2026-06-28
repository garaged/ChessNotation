# ChessNotation

ChessNotation is an iOS SwiftUI app for practicing standard algebraic chess notation from real games. It loads bundled training games, renders the board position for each move, and asks the player to enter the correct SAN move with feedback, hints, and session summaries.

## Current release

- Version: `2.0.2`
- Build: `1`
- Release focus: current-position evaluation, all-mode training history, interactive trend charts, premium visual redesign, timed training, square recognition, and richer game-library previews.

## Current scope

- Launch notation practice, timed notation, square recognition, and instructions from a premium visual home screen.
- Browse the game library with thumbnail board previews for each game.
- Filter by level and opening, or search by title, players, opening, or difficulty.
- Start a random game from the filtered library.
- Train move-by-move with SAN input, hints, reveal, current-position evaluation context, and results.
- Play timed notation sessions with selectable duration, remaining-time display, timeout handling, and timed results.
- Practice square recognition by tapping prompted coordinates with bonus or strict timing variants.
- Review notation, timed notation, and square-recognition history stored on device.
- Filter history by today, last week, last month, or last year with trend charts and tap-to-read values.
- Customize board coordinates, per-difficulty evaluation visibility, and board style.
- Render boards with bundled transparent chess-piece artwork and selectable visual themes: Current, Marble, Wood, and Metal.

## Project structure

- `ChessNotation/ChessNotation/App`: app entry point
- `ChessNotation/ChessNotation/Domain`: shared models and training summary logic
- `ChessNotation/ChessNotation/Features`: SwiftUI screens and feature-specific logic
- `ChessNotation/ChessNotation/Services`: parsing, validation, and bundled game loading
- `ChessNotationTests`: unit and integration coverage
- `ChessNotationUITests`: end-to-end UI coverage
- `specs/features`: active spec-driven development contracts
- `specs/archive/features`: completed accepted specs kept for history

## Requirements

- Xcode 16 or later
- iOS 18 simulator or device target recommended

## Build and run

1. Open `ChessNotation.xcodeproj` in Xcode.
2. Select the `ChessNotation` scheme.
3. Build and run on a simulator or device.

## Testing

The repository includes three layers of coverage:

- Unit tests for parsing, normalization, library filtering, square recognition, and thumbnail preview state
- Integration tests for the training flow state machine
- UI tests for launching the app and completing the first move

Run tests from Xcode or with `Product > Test`.

## Spec-driven development

Feature behavior is documented under [specs/features](specs/features). Accepted
completed specs are retained under [specs/archive/features](specs/archive/features).
Start user-visible changes by adding or updating an active spec, then trace
acceptance criteria to implementation coverage.

Validate specs from the terminal:

```sh
make spec-check
```

See [specs/README.md](specs/README.md) for the workflow, required sections,
status values, and traceability rules.

## AI-assisted development

AI coding agents and AI-assisted contributors should follow [AGENTS.md](AGENTS.md).
That file defines the repository operating contract for spec-driven work,
validation, documentation updates, asset rules, and handoff expectations.

## Bundled game format

Games live in `ChessNotation/ChessNotation/Resources/Games/*.json`.

Each game contains:

- game metadata such as title, players, year, opening, and difficulty
- a move list with SAN, `fenBefore`, source and destination squares, and move tags

The app currently trusts bundled chess data rather than deriving SAN from a rules engine.

## Visual assets

Premium artwork and chess-piece PNGs live in `ChessNotation/ChessNotation/Assets.xcassets`.

- Home and mode tile artwork are referenced through `PremiumAssetName`.
- Chess pieces are referenced by `ChessPiece.imageName` and rendered through `ChessPieceGraphic`.
- Piece image names use the pattern `white-king`, `black-queen`, and so on.
- Piece assets must be PNGs with real alpha transparency so board squares remain visible.

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE).

## Publishing notes

Before publishing publicly or shipping to the App Store, review:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [AGENTS.md](AGENTS.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [PRIVACY.md](PRIVACY.md)
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)
- [CHANGELOG.md](CHANGELOG.md)

## Sponsor

If you like the project and want to support maintenance and new features you can do it at https://github.com/sponsors/garaged
