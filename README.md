# ChessNotation

ChessNotation is an iOS SwiftUI app for practicing standard algebraic chess notation from real games. It loads bundled training games, renders the board position for each move, and asks the player to enter the correct SAN move with feedback, hints, and session summaries.

## Current scope

- Browse the game library from the home screen
- Filter by level
- Filter by opening
- Search by title, players, opening, or difficulty
- Start a random game from the filtered library
- Train move-by-move with SAN input, hints, reveal, and results

## Project structure

- `ChessNotation/ChessNotation/App`: app entry point
- `ChessNotation/ChessNotation/Domain`: shared models and training summary logic
- `ChessNotation/ChessNotation/Features`: SwiftUI screens and feature-specific logic
- `ChessNotation/ChessNotation/Services`: parsing, validation, and bundled game loading
- `ChessNotationTests`: unit and integration coverage
- `ChessNotationUITests`: end-to-end UI coverage

## Requirements

- Xcode 16 or later
- iOS 18 simulator or device target recommended

## Build and run

1. Open `ChessNotation.xcodeproj` in Xcode.
2. Select the `ChessNotation` scheme.
3. Build and run on a simulator or device.

## Testing

The repository includes three layers of coverage:

- Unit tests for parsing, normalization, and library filtering
- Integration tests for the training flow state machine
- UI tests for launching the app and completing the first move

Run tests from Xcode or with `Product > Test`.

## Bundled game format

Games live in `ChessNotation/ChessNotation/Resources/Games/*.json`.

Each game contains:

- game metadata such as title, players, year, opening, and difficulty
- a move list with SAN, `fenBefore`, source and destination squares, and move tags

The app currently trusts bundled chess data rather than deriving SAN from a rules engine.

## License

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE).

## Publishing notes

Before publishing publicly or shipping to the App Store, review:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [PRIVACY.md](PRIVACY.md)
- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)
- [CHANGELOG.md](CHANGELOG.md)

## Sponsor

If you like the project and want to support maintenance and new features you can do it at https://github.com/sponsors/garaged
