# CN-SPEC-0006: Timed Square Recognition Timing and Variants

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

The square-recognition game should reward fast and accurate board recognition.
Time spent between showing a prompt and receiving the player's click is deducted
from the current timer. Two variants should be supported so the same interaction
can be played either with a small correct-answer time bonus or in the intended
strict time-only form.

## Scope

In scope:

- Timing from prompt visibility to square selection.
- Deducting answer latency from remaining time.
- Variant A, `Bonus`: each correct click adds 0.5 seconds after latency is deducted.
- Variant B, `Strict`: correct and incorrect clicks only deduct latency; no bonus time is awarded.
- Incorrect-click behavior.
- Feedback delay before the next prompt.
- Timeout behavior during prompt display and during feedback delay.

Out of scope:

- Streak multipliers.
- Extra penalties for wrong clicks beyond elapsed time.
- Pause/resume behavior.
- Persisted history, which is covered by CN-SPEC-0007.

## Functional Requirements

- CN-SPEC-0006-FR001: The game must record the timestamp when each target coordinate becomes visible.
- CN-SPEC-0006-FR002: On click or tap, the game must compute answer latency as the elapsed time since the current target became visible.
- CN-SPEC-0006-FR003: The game must deduct answer latency from remaining time for both correct and incorrect answers.
- CN-SPEC-0006-FR004: In `Bonus` variant, each correct answer must add 0.5 seconds after latency deduction.
- CN-SPEC-0006-FR005: In `Bonus` variant, an incorrect answer must not add bonus time.
- CN-SPEC-0006-FR006: In `Strict` variant, correct and incorrect answers must not add bonus time.
- CN-SPEC-0006-FR007: After each answer, the game must show answer feedback before the next prompt.
- CN-SPEC-0006-FR008: The default feedback delay must be 0.2 seconds.
- CN-SPEC-0006-FR009: The feedback delay value must be isolated so it can be tuned without changing scoring rules.
- CN-SPEC-0006-FR010: If remaining time reaches zero or less after latency deduction and any bonus application, the game must finish instead of showing another prompt.
- CN-SPEC-0006-FR011: If the timer reaches zero while the player has not answered the visible prompt, the game must finish immediately.
- CN-SPEC-0006-FR012: During the feedback delay, additional clicks must not count as answers for the completed prompt or the next prompt.

## Acceptance Criteria

- CN-SPEC-0006-AC001: Given a prompt appears with 10.0 seconds remaining, when the player clicks the correct square after 1.2 seconds in `Bonus` variant, then remaining time becomes 9.3 seconds before the next prompt is shown.
- CN-SPEC-0006-AC002: Given a prompt appears with 10.0 seconds remaining, when the player clicks the wrong square after 1.2 seconds in `Bonus` variant, then remaining time becomes 8.8 seconds before the next prompt is shown.
- CN-SPEC-0006-AC003: Given a prompt appears with 10.0 seconds remaining, when the player clicks the correct square after 1.2 seconds in `Strict` variant, then remaining time becomes 8.8 seconds before the next prompt is shown.
- CN-SPEC-0006-AC004: Given a prompt appears with 10.0 seconds remaining, when the player clicks the wrong square after 1.2 seconds in `Strict` variant, then remaining time becomes 8.8 seconds before the next prompt is shown.
- CN-SPEC-0006-AC005: Given any answer is evaluated while time remains, when feedback is shown, then the next prompt does not appear until the 0.2-second feedback delay has elapsed.
- CN-SPEC-0006-AC006: Given an answer leaves remaining time at zero or less, when scoring is applied, then the session ends and no next prompt is generated.
- CN-SPEC-0006-AC007: Given the timer reaches zero while a prompt is visible, when no answer has been clicked, then the session ends as timed out.
- CN-SPEC-0006-AC008: Given feedback is visible after an answer, when the player taps the board during the 0.2-second delay, then that tap is ignored for scoring and prompt progression.
- CN-SPEC-0006-AC009: Given feedback delay tuning changes from 0.2 seconds to another value, when scoring tests run, then scoring outcomes are unchanged.
- CN-SPEC-0006-AC010: Given time calculations produce fractional seconds, when remaining time is stored, then it preserves enough precision to apply the 0.5-second bonus accurately.

## Coverage

- `ChessNotationTests/SquareRecognitionTests.swift`: CN-SPEC-0006-AC001, CN-SPEC-0006-AC002, CN-SPEC-0006-AC003, CN-SPEC-0006-AC004, CN-SPEC-0006-AC005, CN-SPEC-0006-AC006, CN-SPEC-0006-AC007, CN-SPEC-0006-AC008, CN-SPEC-0006-AC009, CN-SPEC-0006-AC010
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViewModel.swift`: CN-SPEC-0006-AC001, CN-SPEC-0006-AC002, CN-SPEC-0006-AC003, CN-SPEC-0006-AC004, CN-SPEC-0006-AC005, CN-SPEC-0006-AC006, CN-SPEC-0006-AC007, CN-SPEC-0006-AC008, CN-SPEC-0006-AC009, CN-SPEC-0006-AC010

## Open Questions

- Resolved: Bonus time is not capped in the first implementation.
- Resolved: Square-recognition time displays in tenths.

## Revision Notes

- 2026-06-27: Initial proposed spec for timed square-recognition timing and scoring variants.
- 2026-06-27: Confirmed `Strict` as the intended variant B.
- 2026-06-28: Accepted after implementation and coverage audit.
