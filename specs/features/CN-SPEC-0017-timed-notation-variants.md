# CN-SPEC-0017: Timed Notation Variants

Status: Proposed
Owner: Project
Last updated: 2026-07-07

## Intent

Make timed notation meaningfully different from untimed play by defining sprint, accuracy-race, survival, and combo variants with deterministic scoring and deadline-based timing that remains correct across delays and app lifecycle changes.

## Scope

In scope:

- Sprint, accuracy race, survival, and combo timed variants.
- Injected monotonic clock/deadline behavior.
- Pure scoring rules for correctness, latency, SAN complexity, streaks, hints, and penalties.
- Pause/background/foreground policy, timeout, result persistence, and personal-best metadata.

Out of scope:

- Online competition, shared leaderboards, anti-cheat, or Game Center.
- Runtime chess-engine analysis.
- Untimed drill generation except reuse of CN-SPEC-0015 and CN-SPEC-0016 candidates.

## Functional Requirements

- CN-SPEC-0017-FR001: Sprint must use a fixed deadline and score as many independently generated prompts as the player resolves before time expires.
- CN-SPEC-0017-FR002: Accuracy race must use a fixed prompt count, measure elapsed completion time, and apply documented time or score penalties for incorrect attempts, hints, or reveals.
- CN-SPEC-0017-FR003: Survival must begin with configured time, add bounded time for correct answers, deduct bounded time for incorrect answers, and increase challenge difficulty through documented stages.
- CN-SPEC-0017-FR004: Combo must increase a capped multiplier for consecutive correct answers and reset or reduce it after an incorrect resolved challenge.
- CN-SPEC-0017-FR005: A pure timed scorer must return a transparent score breakdown containing base, speed, complexity, streak, hint/reveal penalties, and final total.
- CN-SPEC-0017-FR006: Speed scoring must be capped and must never reward answers below a documented minimum plausible latency enough to dominate correctness.
- CN-SPEC-0017-FR007: Timing correctness must derive from an injected monotonic clock and absolute deadline or elapsed-time model, not from assuming every UI timer tick arrives exactly once per second.
- CN-SPEC-0017-FR008: Display refresh frequency may be reduced for efficiency without changing the authoritative remaining time or finish outcome.
- CN-SPEC-0017-FR009: When the app becomes inactive, each variant must follow one documented policy: continue against its deadline or pause by adjusting the deadline; the policy must be consistent and testable.
- CN-SPEC-0017-FR010: Submissions at or after expiration must not score or advance, while a valid submission strictly before expiration must resolve even if the UI refresh arrives later.
- CN-SPEC-0017-FR011: Finishing and history saving must be idempotent under simultaneous timeout, answer submission, navigation, or repeated lifecycle events.
- CN-SPEC-0017-FR012: Results must include variant, configuration, score breakdown totals, prompt metrics, streak, timing, difficulty stages, finish reason, and source challenge categories.
- CN-SPEC-0017-FR013: Existing simple timed-notation duration behavior and history must remain readable and map to a documented legacy sprint-compatible representation unless intentionally retained as a separate classic variant.
- CN-SPEC-0017-FR014: Timer updates must not trigger unnecessary regeneration, FEN parsing, library indexing, or whole-screen expensive work.
- CN-SPEC-0017-FR015: Low-time and correctness feedback must not rely on color alone and must respect reduced-motion and haptic settings.

## Acceptance Criteria

- CN-SPEC-0017-AC001: Given sprint with a deterministic clock, when time advances past the deadline, then the session finishes once and ignores later submissions.
- CN-SPEC-0017-AC002: Given accuracy race with N prompts, when prompt N resolves before timeout policy applies, then elapsed time and penalties produce the documented final result.
- CN-SPEC-0017-AC003: Given survival, when a correct and then incorrect answer occur, then time changes by the configured bounded bonuses/penalties and never exceeds the documented cap or drops below zero.
- CN-SPEC-0017-AC004: Given combo, when consecutive correct answers occur and then an incorrect answer resolves, then multiplier growth is capped and the reset rule is applied exactly.
- CN-SPEC-0017-AC005: Given fixed scoring inputs, when the pure scorer runs repeatedly, then every score component and total are identical.
- CN-SPEC-0017-AC006: Given an implausibly fast latency, when scored, then the speed component is capped and cannot make an incorrect or revealed answer outperform the documented correct-answer floor.
- CN-SPEC-0017-AC007: Given UI timer callbacks are delayed or skipped, when authoritative time is queried, then remaining time and timeout match the injected clock rather than callback count.
- CN-SPEC-0017-AC008: Given an answer is submitted just before deadline and processed after a delayed refresh, then it is accepted according to its captured monotonic timestamp.
- CN-SPEC-0017-AC009: Given an answer timestamp is at or after deadline, when submitted, then it is ignored and cannot add score or history prompts.
- CN-SPEC-0017-AC010: Given timeout and submission race, when both attempt to finish the session, then one final result and one history record are created.
- CN-SPEC-0017-AC011: Given background and foreground transitions, when the selected lifecycle policy is applied, then elapsed/remaining time follows that policy exactly.
- CN-SPEC-0017-AC012: Given a legacy timed history record, when loaded, then its duration, time used, completed moves, accuracy, finish reason, and moves per minute remain available.
- CN-SPEC-0017-AC013: Given reduced motion or haptics disabled, when low-time and answer feedback occur, then equivalent text/symbol feedback remains and disabled effects do not run.
- CN-SPEC-0017-AC014: Given a representative ten-minute timed run, when profiling counters or performance tests execute, then timer refreshes do not rebuild indexes or parse unchanged FEN data and retained memory remains stable.

## Coverage

- Pending coverage: CN-SPEC-0017-AC001
- Pending coverage: CN-SPEC-0017-AC002
- Pending coverage: CN-SPEC-0017-AC003
- Pending coverage: CN-SPEC-0017-AC004
- Pending coverage: CN-SPEC-0017-AC005
- Pending coverage: CN-SPEC-0017-AC006
- Pending coverage: CN-SPEC-0017-AC007
- Pending coverage: CN-SPEC-0017-AC008
- Pending coverage: CN-SPEC-0017-AC009
- Pending coverage: CN-SPEC-0017-AC010
- Pending coverage: CN-SPEC-0017-AC011
- Pending coverage: CN-SPEC-0017-AC012
- Pending coverage: CN-SPEC-0017-AC013
- Pending coverage: CN-SPEC-0017-AC014

## Open Questions

- None. The implementation spec review must choose and document one lifecycle policy per variant before acceptance.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR3.