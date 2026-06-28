# CN-SPEC-0004: Timed Game Results and UI

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

Timed mode should give players clear time pressure during play and a results
summary that explains how the run ended. The UI should preserve the current
game's direct interaction model while adding concise timer and timed-result
signals.

## Scope

In scope:

- Displaying remaining time during timed play.
- Warning states as time runs low.
- Results fields specific to timed sessions.
- Restarting a timed game with the same game and selected duration.
- Accessibility labels for timed controls and timer state.

Out of scope:

- Visual redesign of the whole app.
- Global statistics across multiple timed sessions.
- Game Center, sharing, or leaderboard features.
- Sound effects or haptics.

## Functional Requirements

- CN-SPEC-0004-FR001: The game screen must show remaining time for timed sessions in minutes and seconds.
- CN-SPEC-0004-FR002: The timer display must be omitted or visually inactive for untimed sessions.
- CN-SPEC-0004-FR003: The timed game screen must expose accessible labels for remaining time, selected duration, and timed mode state.
- CN-SPEC-0004-FR004: When a timed session has 10 seconds or less remaining, the timer must enter a low-time warning state.
- CN-SPEC-0004-FR005: Results must show whether the timed session ended by completion, timeout, or manual exit.
- CN-SPEC-0004-FR006: Results for timed sessions must show selected duration, time used, moves attempted, correct moves, incorrect moves, and accuracy.
- CN-SPEC-0004-FR007: Restarting from timed results must start the same game again with the same selected duration.
- CN-SPEC-0004-FR008: Starting a new game from timed results must return to the library without preserving the finished timer state.
- CN-SPEC-0004-FR009: Timed UI updates must avoid hiding the current board, answer field, attempts, or feedback.

## Acceptance Criteria

- CN-SPEC-0004-AC001: Given a 3-minute timed game starts, when the game screen appears, then the timer reads `3:00`.
- CN-SPEC-0004-AC002: Given an untimed game starts, when the game screen appears, then no active countdown timer is presented.
- CN-SPEC-0004-AC003: Given a timed game has 9 seconds remaining, when the game screen renders, then the timer is in a low-time warning state.
- CN-SPEC-0004-AC004: Given VoiceOver queries the timed game screen, when the timer is focused, then the accessible label includes the remaining time and timed mode context.
- CN-SPEC-0004-AC005: Given a timed session completes all moves before timeout, when results appear, then results identify the finish reason as completed.
- CN-SPEC-0004-AC006: Given a timed session reaches zero before all moves are complete, when results appear, then results identify the finish reason as timed out.
- CN-SPEC-0004-AC007: Given timed results are shown, when the summary is inspected, then selected duration, time used, moves attempted, correct moves, incorrect moves, and accuracy are present.
- CN-SPEC-0004-AC008: Given timed results are shown, when the player taps restart, then the same game restarts with the same selected duration and full time remaining.
- CN-SPEC-0004-AC009: Given timed results are shown, when the player chooses a new game, then the library appears and the completed timer state is cleared.
- CN-SPEC-0004-AC010: Given the timed game screen is narrow, when the board, timer, answer field, attempts, and feedback render, then none of those elements overlap or become unusable.

## Coverage

- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0004-AC001, CN-SPEC-0004-AC002, CN-SPEC-0004-AC004, CN-SPEC-0004-AC005, CN-SPEC-0004-AC007, CN-SPEC-0004-AC010
- `ChessNotationTests/GameViewModelIntegrationTests.swift`: CN-SPEC-0004-AC001, CN-SPEC-0004-AC003, CN-SPEC-0004-AC005, CN-SPEC-0004-AC006, CN-SPEC-0004-AC007, CN-SPEC-0004-AC008
- `ChessNotation/Features/Game/GameTrainingView.swift`: CN-SPEC-0004-AC001, CN-SPEC-0004-AC002, CN-SPEC-0004-AC003, CN-SPEC-0004-AC004, CN-SPEC-0004-AC010
- `ChessNotation/Features/Results/ResultsView.swift`: CN-SPEC-0004-AC005, CN-SPEC-0004-AC006, CN-SPEC-0004-AC007, CN-SPEC-0004-AC008, CN-SPEC-0004-AC009

## Open Questions

- Resolved: Low-time warning is visual only in the first implementation.
- Resolved: Moves per minute is deferred to history work; initial timed results show selected duration, time used, attempts, correct, incorrect, and accuracy.

## Revision Notes

- 2026-06-27: Initial proposed spec for timed game results and UI.
- 2026-06-28: Accepted after implementation and coverage audit.
