# CN-SPEC-0005: Timed Square Recognition Setup

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

Players should be able to practice board-square recognition under time pressure.
The game presents a square coordinate, the player clicks or taps the matching
board square, and the session continues until the timer reaches zero.

## Scope

In scope:

- A new timed square-recognition game mode.
- Pre-game configuration for initial time and scoring variant.
- Default initial time of 10 seconds.
- A board interaction where the player selects the prompted square.
- Prompt generation for valid chessboard coordinates from `a1` through `h8`.
- Reusing existing board orientation and theme conventions where practical.
- Applying the shared board coordinate display option defined by CN-SPEC-0008.

Out of scope:

- Chess move legality, SAN notation, or game-library move progression.
- Online play, leaderboards, or user accounts.
- Piece placement questions.
- Requiring shared infrastructure with other timed games unless it is easy and
  does not complicate this game.

## Functional Requirements

- CN-SPEC-0005-FR001: The app must expose a timed square-recognition game separately from the current notation training flow.
- CN-SPEC-0005-FR002: The default initial time must be 10 seconds.
- CN-SPEC-0005-FR003: Before starting, the player must be able to configure the initial time.
- CN-SPEC-0005-FR004: Before starting, the player must be able to choose one of the supported scoring variants.
- CN-SPEC-0005-FR005: The game must present one target coordinate at a time using valid algebraic square notation from `a1` through `h8`.
- CN-SPEC-0005-FR006: The player must answer by clicking or tapping a square on the board.
- CN-SPEC-0005-FR007: The game must compare the selected square to the current target coordinate.
- CN-SPEC-0005-FR008: After each answer and feedback delay, the next prompt must be generated from the full set of valid board squares.
- CN-SPEC-0005-FR009: The game must not require a bundled chess game or notation move list to run.
- CN-SPEC-0005-FR010: The square-recognition game must be usable with touch and pointer input.
- CN-SPEC-0005-FR011: The square-recognition board must apply the shared coordinate-display setting defined by CN-SPEC-0008.

## Acceptance Criteria

- CN-SPEC-0005-AC001: Given the player opens the square-recognition setup, when no custom time is selected, then the initial time is 10 seconds.
- CN-SPEC-0005-AC002: Given the player changes the initial time before starting, when the game begins, then the timer starts from the selected value.
- CN-SPEC-0005-AC003: Given setup is shown, when the player reviews variants, then both supported variants are selectable.
- CN-SPEC-0005-AC004: Given a square-recognition session starts, when the first prompt appears, then the prompt is a valid coordinate from `a1` through `h8`.
- CN-SPEC-0005-AC005: Given a prompt is visible, when the player taps the prompted square, then the answer is evaluated as correct.
- CN-SPEC-0005-AC006: Given a prompt is visible, when the player taps any different square, then the answer is evaluated as incorrect.
- CN-SPEC-0005-AC007: Given an answer has been evaluated and the feedback delay has elapsed, when time remains, then a new target coordinate is shown.
- CN-SPEC-0005-AC008: Given the player starts square recognition, when the game runs, then no bundled notation game or SAN move validation is required.
- CN-SPEC-0005-AC009: Given the board is displayed on iPhone and iPad layouts, when a player uses touch or pointer input, then each square can be selected without overlap with other controls.
- CN-SPEC-0005-AC010: Given coordinate display is enabled, when square recognition starts, then the board shows classic in-board coordinates without blocking square selection.

## Coverage

- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0005-AC003, CN-SPEC-0005-AC004, CN-SPEC-0005-AC005, CN-SPEC-0005-AC009
- `ChessNotationTests/SquareRecognitionTests.swift`: CN-SPEC-0005-AC001, CN-SPEC-0005-AC002, CN-SPEC-0005-AC004, CN-SPEC-0005-AC005, CN-SPEC-0005-AC006, CN-SPEC-0005-AC007, CN-SPEC-0005-AC008
- `ChessNotationTests/NotationServicesTests.swift`: CN-SPEC-0005-AC010
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViews.swift`: CN-SPEC-0005-AC001, CN-SPEC-0005-AC002, CN-SPEC-0005-AC003, CN-SPEC-0005-AC009, CN-SPEC-0005-AC010
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViewModel.swift`: CN-SPEC-0005-AC004, CN-SPEC-0005-AC005, CN-SPEC-0005-AC006, CN-SPEC-0005-AC007, CN-SPEC-0005-AC008

## Open Questions

- Resolved: The first implementation offers 10, 30, and 60 seconds.
- Resolved: Immediate prompt repeats are allowed in the first implementation.
- Resolved: Board orientation is fixed from White's perspective.

## Revision Notes

- 2026-06-27: Initial proposed spec for timed square-recognition setup and prompt interaction.
- 2026-06-27: Added dependency on shared board coordinate display.
- 2026-06-28: Accepted after implementation and coverage audit.
