# CN-SPEC-0001: Core Training Experience

Status: Accepted
Owner: Project
Last updated: 2026-06-27

## Intent

ChessNotation helps a player practice standard algebraic notation from real
games. The core experience must let a player choose a bundled game, inspect the
current board state, enter SAN for each highlighted move, and finish with a
session result.

## Scope

In scope:

- Loading bundled notation games.
- Browsing and filtering the bundled game library.
- Rendering the board for the active move.
- Validating SAN answers with user-friendly normalization.
- Managing attempts, hints, skips, resets, and results.
- Decoding optional engine evaluation data included with game moves.

Out of scope:

- Generating legal moves from a chess engine.
- Downloading games from remote services.
- User accounts, cloud sync, or persistent training history.

## Functional Requirements

- CN-SPEC-0001-FR001: The app must decode bundled game JSON as either a single game object or an array of game objects.
- CN-SPEC-0001-FR002: The home library must support filtering by difficulty, opening, and free-text search across useful game metadata.
- CN-SPEC-0001-FR003: The game view model must advance after a correct SAN answer and record the successful attempt.
- CN-SPEC-0001-FR004: The answer validator must ignore leading and trailing whitespace and normalize castling written with zeroes.
- CN-SPEC-0001-FR005: Incorrect attempts must provide hints without revealing the exact SAN answer or destination square before attempts are exhausted.
- CN-SPEC-0001-FR006: Exhausting attempts or skipping a move must record an incorrect result and continue the session.
- CN-SPEC-0001-FR007: Resetting a session must return the player to the first move with no prior records.
- CN-SPEC-0001-FR008: The FEN parser must build a complete 64-square board for the start position and regular FEN strings.
- CN-SPEC-0001-FR009: Optional engine evaluations must decode and expose display text and white-advantage fractions consistently.
- CN-SPEC-0001-FR010: UI flows must let a player launch the app, select a game, enter the first move, filter the library by level, and restart after results.

## Acceptance Criteria

- CN-SPEC-0001-AC001: Given bundled game JSON containing one game object, when it is decoded, then the library returns that single game with its moves.
- CN-SPEC-0001-AC002: Given bundled game JSON containing an array of games, when it is decoded, then the library returns each game in source order.
- CN-SPEC-0001-AC003: Given library filters for difficulty, opening, or search text, when they are applied, then only matching games remain and opening filter options are sorted.
- CN-SPEC-0001-AC004: Given a SAN answer with extra whitespace or zero-based castling notation, when it is validated, then it matches the intended move.
- CN-SPEC-0001-AC005: Given the start position, when board squares are parsed, then 64 coordinates are produced with the expected initial pieces.
- CN-SPEC-0001-AC006: Given a correct answer for the current move, when the answer is submitted, then the view model advances, clears input, records success, and resets feedback.
- CN-SPEC-0001-AC007: Given three incorrect attempts, when the third answer is submitted, then the move is recorded as incorrect and the session advances with attempts reset.
- CN-SPEC-0001-AC008: Given an incorrect answer before attempts are exhausted, when feedback is shown, then the feedback does not reveal the SAN answer or destination square.
- CN-SPEC-0001-AC009: Given optional engine evaluation payloads, when they are decoded, then missing, centipawn, and mate scores produce the expected display values and advantage fractions.
- CN-SPEC-0001-AC010: Given a player skips a move and then resets the session, when the view model state is inspected, then records are cleared and the session starts at move one.
- CN-SPEC-0001-AC011: Given the app is launched in UI tests, when the player selects the Opera Game and enters `e4`, then progress advances to move two.
- CN-SPEC-0001-AC012: Given the sample UI test library, when the Advanced level filter is selected, then beginner games are hidden and advanced games remain.
- CN-SPEC-0001-AC013: Given a one-move sample UI test game, when the player finishes and taps restart, then the game returns to move one.

## Coverage

- `ChessNotationTests/NotationServicesTests.swift`: CN-SPEC-0001-AC001, CN-SPEC-0001-AC002, CN-SPEC-0001-AC003, CN-SPEC-0001-AC004, CN-SPEC-0001-AC005, CN-SPEC-0001-AC009
- `ChessNotationTests/GameViewModelIntegrationTests.swift`: CN-SPEC-0001-AC006, CN-SPEC-0001-AC007, CN-SPEC-0001-AC008, CN-SPEC-0001-AC010
- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0001-AC011, CN-SPEC-0001-AC012, CN-SPEC-0001-AC013

## Open Questions

- None.

## Revision Notes

- 2026-06-27: Initial baseline spec documenting current behavior.
