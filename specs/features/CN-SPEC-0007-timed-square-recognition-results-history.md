# CN-SPEC-0007: Timed Square Recognition Results History

Status: Proposed
Owner: Project
Last updated: 2026-06-27

## Intent

When a square-recognition game ends, the player should see useful statistics
for that run and be able to review historical results over time. The history
should make improvement visible without requiring accounts or network services.

## Scope

In scope:

- End-of-game statistics when time runs out.
- Persisting completed square-recognition results on device.
- Displaying historical results for the square-recognition game.
- Supporting both scoring variants in the stored result model.
- Optional reuse for future timed games when it stays simple.

Out of scope:

- Cloud sync.
- Online leaderboards.
- User profiles.
- Importing or exporting history.
- Complex analytics beyond run summaries and trend-friendly fields.

## Functional Requirements

- CN-SPEC-0007-FR001: When time runs out, the game must show a results screen instead of returning directly to setup.
- CN-SPEC-0007-FR002: Results must include total prompts answered, correct count, incorrect count, accuracy, average answer latency, fastest correct answer, slowest answer, configured initial time, scoring variant, and finish timestamp.
- CN-SPEC-0007-FR003: Results must include final score as the number of correct square selections.
- CN-SPEC-0007-FR004: Results must preserve enough per-run data to compare performance over time.
- CN-SPEC-0007-FR005: Completed square-recognition results must be stored locally on the device.
- CN-SPEC-0007-FR006: The history view must show previous square-recognition results in reverse chronological order.
- CN-SPEC-0007-FR007: The history view must make development over time visible using at least date, score, accuracy, average latency, initial time, and scoring variant.
- CN-SPEC-0007-FR008: A run with zero answered prompts must still produce a valid result and history entry.
- CN-SPEC-0007-FR009: Starting a new square-recognition game from results must not delete prior history.
- CN-SPEC-0007-FR010: Shared timed-game result infrastructure may be introduced only if it stays simple and does not delay the square-recognition implementation.

## Acceptance Criteria

- CN-SPEC-0007-AC001: Given a square-recognition game reaches zero time, when results appear, then total prompts, correct count, incorrect count, accuracy, average latency, fastest correct answer, slowest answer, initial time, variant, score, and finish timestamp are visible or accessible.
- CN-SPEC-0007-AC002: Given a game ends after 12 answers with 9 correct, when results are calculated, then score is 9 and accuracy is 75%.
- CN-SPEC-0007-AC003: Given a game ends before any prompt is answered, when results are calculated, then score is 0, accuracy is 0%, and latency fields handle the empty run without crashing.
- CN-SPEC-0007-AC004: Given a completed square-recognition result, when persistence succeeds, then the result appears in history after app relaunch.
- CN-SPEC-0007-AC005: Given multiple completed results exist, when history is shown, then the newest result appears first.
- CN-SPEC-0007-AC006: Given historical results use different initial times and variants, when history is shown, then each row identifies its initial time and scoring variant.
- CN-SPEC-0007-AC007: Given the player reviews history, when they compare entries, then score, accuracy, and average latency are visible enough to judge development over time.
- CN-SPEC-0007-AC008: Given the player starts a new square-recognition game from the results screen, when the new game begins, then previous history entries remain available.
- CN-SPEC-0007-AC009: Given result storage fails, when the game ends, then the current results are still shown and the player is not blocked from starting another game.
- CN-SPEC-0007-AC010: Given another timed game later needs history, when shared result infrastructure is easy to reuse, then it can store game type without changing square-recognition result semantics.

## Coverage

- Pending coverage: CN-SPEC-0007-AC001
- Pending coverage: CN-SPEC-0007-AC002
- Pending coverage: CN-SPEC-0007-AC003
- Pending coverage: CN-SPEC-0007-AC004
- Pending coverage: CN-SPEC-0007-AC005
- Pending coverage: CN-SPEC-0007-AC006
- Pending coverage: CN-SPEC-0007-AC007
- Pending coverage: CN-SPEC-0007-AC008
- Pending coverage: CN-SPEC-0007-AC009
- Pending coverage: CN-SPEC-0007-AC010

## Open Questions

- Should history have a maximum retained count or age?
- Should users be able to clear square-recognition history?
- Should the first implementation include a chart, or is a sortable/list view enough?

## Revision Notes

- 2026-06-27: Initial proposed spec for timed square-recognition results and history.
