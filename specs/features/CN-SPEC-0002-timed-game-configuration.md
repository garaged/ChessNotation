# CN-SPEC-0002: Timed Game Configuration

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

Players should be able to start a timed notation game from the existing game
library without losing the current untimed training flow. The timed mode should
reuse bundled games, filters, notation input, and board presentation while
adding a clear time limit before the session begins.

## Scope

In scope:

- Exposing timed mode from the existing home/game selection experience.
- Selecting a time limit before launch.
- Starting timed mode from a chosen bundled game.
- Preserving the existing untimed game as the default-compatible mode.
- Passing the selected mode and time limit into the game session state.
- Applying the shared board coordinate display option defined by CN-SPEC-0008.

Out of scope:

- Downloading timed puzzles or remote game content.
- Persisting custom time presets across launches.
- Online leaderboards or player accounts.
- Changing SAN validation rules.

## Functional Requirements

- CN-SPEC-0002-FR001: The app must offer both untimed training and timed game modes without removing the current untimed path.
- CN-SPEC-0002-FR002: Timed mode must use the same bundled game library, difficulty filters, opening filters, and search behavior as untimed mode.
- CN-SPEC-0002-FR003: Before starting timed mode, the player must choose one supported time limit.
- CN-SPEC-0002-FR004: Supported time limits must include 1 minute, 3 minutes, and 5 minutes.
- CN-SPEC-0002-FR005: The selected time limit must be attached to the launched game session and exposed to the session state.
- CN-SPEC-0002-FR006: Starting untimed mode must not create a countdown timer or time-expiration finish condition.
- CN-SPEC-0002-FR007: Starting timed mode must initialize the timer with the full selected duration and the first move active.
- CN-SPEC-0002-FR008: Timed notation game boards must apply the shared coordinate-display setting defined by CN-SPEC-0008.

## Acceptance Criteria

- CN-SPEC-0002-AC001: Given the player is on the home screen, when they choose a game, then they can start either untimed training or timed mode.
- CN-SPEC-0002-AC002: Given the player applies existing library filters, when timed mode is selected, then the same filtered games are available.
- CN-SPEC-0002-AC003: Given timed mode is selected, when the start control is shown, then 1 minute, 3 minutes, and 5 minutes are available choices.
- CN-SPEC-0002-AC004: Given the player selects a 3-minute timed game, when the session starts, then the session has 180 seconds remaining and starts at move one.
- CN-SPEC-0002-AC005: Given the player starts untimed training, when the game screen appears, then no countdown is active and timeout cannot finish the session.
- CN-SPEC-0002-AC006: Given timed mode is launched, when the first move is shown, then the board, highlighted move, notation input, and feedback rules match the current training game.
- CN-SPEC-0002-AC007: Given coordinate display is enabled, when timed mode is launched, then the timed notation board shows classic in-board coordinates.

## Coverage

- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0002-AC001, CN-SPEC-0002-AC002, CN-SPEC-0002-AC003, CN-SPEC-0002-AC005, CN-SPEC-0002-AC006
- `ChessNotationTests/GameViewModelIntegrationTests.swift`: CN-SPEC-0002-AC004, CN-SPEC-0002-AC005
- `ChessNotationTests/NotationServicesTests.swift`: CN-SPEC-0002-AC007
- `ChessNotation/Features/Home/HomeView.swift`: CN-SPEC-0002-AC001, CN-SPEC-0002-AC002, CN-SPEC-0002-AC003
- `ChessNotation/Features/Game/GameTrainingView.swift`: CN-SPEC-0002-AC006, CN-SPEC-0002-AC007

## Open Questions

- Resolved: Timed mode is entered from the Home Timed Notation tile and uses the shared Game Library in timed launch mode.
- Resolved: Custom time limits are deferred; the first implementation supports 1, 3, and 5 minutes.

## Revision Notes

- 2026-06-27: Initial proposed spec for timed game configuration.
- 2026-06-27: Added dependency on shared board coordinate display.
- 2026-06-28: Accepted after implementation and coverage audit.
