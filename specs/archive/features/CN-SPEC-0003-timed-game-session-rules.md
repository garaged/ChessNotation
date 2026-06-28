# CN-SPEC-0003: Timed Game Session Rules

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

A timed game should feel like the current notation training game under time
pressure. Correct answers, incorrect attempts, hints, skips, and progression
should behave consistently with untimed training, with the additional rule that
the session ends when time expires.

## Scope

In scope:

- Countdown lifecycle for a timed session.
- Move progression while time remains.
- Handling correct answers, incorrect answers, exhausted attempts, and skips.
- Session completion by checkmate of content, manual exit, or timeout.
- Timer behavior while the app moves between active game and results screens.

Out of scope:

- Background execution after the app is suspended.
- Anti-cheat protections.
- Network clock synchronization.
- Animated countdown styling.

## Functional Requirements

- CN-SPEC-0003-FR001: A timed session must count down once the game screen is active.
- CN-SPEC-0003-FR002: The timer must stop when the session reaches results, whether by completing moves or by timeout.
- CN-SPEC-0003-FR003: A correct SAN answer must advance to the next move and record success using the same validation behavior as untimed training.
- CN-SPEC-0003-FR004: Incorrect attempts must decrement attempts and provide hints using the same non-revealing rules as untimed training.
- CN-SPEC-0003-FR005: Exhausting attempts must record the move as incorrect and advance while time remains.
- CN-SPEC-0003-FR006: Skipping a move must record the move as incorrect and advance while time remains.
- CN-SPEC-0003-FR007: If time reaches zero during an active move, the session must finish immediately with a timeout reason.
- CN-SPEC-0003-FR008: If the final move is answered, skipped, or exhausted before time expires, the session must finish as completed rather than timed out.
- CN-SPEC-0003-FR009: After a timed session finishes, further answer submissions and timer ticks must not mutate records, score, or progress.
- CN-SPEC-0003-FR010: Resetting a timed session must restore the original selected duration, clear records, clear answer text, and return to the first move.

## Acceptance Criteria

- CN-SPEC-0003-AC001: Given a timed session has started, when one second elapses, then remaining time decreases by one second.
- CN-SPEC-0003-AC002: Given a timed session is active, when a correct SAN answer is submitted, then the session advances and records success exactly as untimed training does.
- CN-SPEC-0003-AC003: Given a timed session is active, when an incorrect answer is submitted before attempts are exhausted, then attempts decrease and feedback does not reveal the SAN answer or destination square.
- CN-SPEC-0003-AC004: Given a timed session is active, when attempts are exhausted for a move, then that move is recorded as incorrect and the next move is shown if time remains.
- CN-SPEC-0003-AC005: Given a timed session is active, when the player skips a move, then that move is recorded as incorrect and the next move is shown if time remains.
- CN-SPEC-0003-AC006: Given a timed session has one second remaining, when the next timer tick occurs before an answer is accepted, then the session finishes with timeout.
- CN-SPEC-0003-AC007: Given the player answers the final move before time expires, when results are shown, then the finish reason is completed and the timer is stopped.
- CN-SPEC-0003-AC008: Given a timed session has finished, when timer ticks or answer submissions occur, then progress, records, and finish reason do not change.
- CN-SPEC-0003-AC009: Given a timed session has progressed, when the player restarts it, then remaining time returns to the selected duration and move one is active.
- CN-SPEC-0003-AC010: Given an untimed session is active, when time-related update logic is invoked, then the session does not finish by timeout.

## Coverage

- `ChessNotationTests/GameViewModelIntegrationTests.swift`: CN-SPEC-0003-AC001, CN-SPEC-0003-AC002, CN-SPEC-0003-AC003, CN-SPEC-0003-AC004, CN-SPEC-0003-AC005, CN-SPEC-0003-AC006, CN-SPEC-0003-AC007, CN-SPEC-0003-AC008, CN-SPEC-0003-AC009, CN-SPEC-0003-AC010
- `ChessNotation/Features/Game/GameViewModel.swift`: CN-SPEC-0003-AC001, CN-SPEC-0003-AC006, CN-SPEC-0003-AC007, CN-SPEC-0003-AC008, CN-SPEC-0003-AC009, CN-SPEC-0003-AC010

## Open Questions

- Resolved: Countdown starts when the active game screen task runs for a timed session.
- Resolved: Event ordering follows the view model call order; once timeout finishes the session, later submissions are ignored.

## Revision Notes

- 2026-06-27: Initial proposed spec for timed game session behavior.
- 2026-06-28: Accepted after implementation and coverage audit.
