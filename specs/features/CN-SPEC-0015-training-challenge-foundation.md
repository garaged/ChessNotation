# CN-SPEC-0015: Training Challenge Foundation

Status: Proposed
Owner: Project
Last updated: 2026-07-07

## Intent

Provide a deterministic, efficient, and testable foundation for generating varied training challenges across ChessNotation without coupling domain rules to SwiftUI, global randomness, wall-clock time, persistence, or a specific mini-game.

## Scope

In scope:

- Shared challenge identity, kind, source, difficulty, prompt metadata, and session-configuration contracts.
- Injectable randomization, clocks, and challenge-generation boundaries.
- Seeded and scripted generation for reproducible tests.
- Duplicate avoidance, shuffled-bag selection, bounded generation, cancellation, and explicit fallback behavior.
- Lazy challenge production and reusable indexes over bundled game data.
- Common result metadata needed by future training modes.

Out of scope:

- User-facing game screens.
- Mode-specific scoring or answer validation.
- A complete chess-rules engine.
- Networking, telemetry, accounts, cloud sync, or remote content.
- Replacing existing history models before a consuming spec requires migration.

## Functional Requirements

- CN-SPEC-0015-FR001: Domain challenge types must be value-oriented, strongly typed, independent of SwiftUI, and safe to compare in tests.
- CN-SPEC-0015-FR002: Each generated challenge must have a stable session-local identity, challenge kind, difficulty, source metadata, and enough data for its consumer to render and validate the prompt without re-querying mutable global state.
- CN-SPEC-0015-FR003: Random selection must be supplied through a protocol or equivalent injected boundary; production may use system randomness while tests can use deterministic seeds or scripted values.
- CN-SPEC-0015-FR004: The same eligible inputs, configuration, and deterministic seed must produce the same challenge sequence.
- CN-SPEC-0015-FR005: A generator must avoid an immediate duplicate when at least one different eligible challenge exists.
- CN-SPEC-0015-FR006: Shuffled-bag selection must visit every currently eligible item once before beginning a new cycle, except when eligibility changes or a documented fallback is required.
- CN-SPEC-0015-FR007: Generation must have a finite attempt bound and return an explicit unavailable or fallback outcome instead of looping indefinitely.
- CN-SPEC-0015-FR008: Empty, malformed, filtered-to-zero, or undersized source collections must produce predictable recoverable outcomes and must not crash.
- CN-SPEC-0015-FR009: Challenges must be generated lazily or in bounded batches rather than eagerly materializing an unbounded session.
- CN-SPEC-0015-FR010: Reusable indexes over bundled game data must be immutable after construction, must not be rebuilt for each prompt, and must support lookup by game, difficulty, opening, move tag, and other later-approved dimensions.
- CN-SPEC-0015-FR011: Expensive loading, decoding, indexing, and filtering must not execute from a SwiftUI view body.
- CN-SPEC-0015-FR012: Generator work that can outlive a screen must support cancellation or ownership rules that prevent stale results from mutating a newer session.
- CN-SPEC-0015-FR013: Session configuration and result metadata must be schema-versioned and preserve the selected mode, difficulty, filters, seed policy, start time, finish time, and finish reason when applicable.
- CN-SPEC-0015-FR014: New foundation types must not change current notation, timed-notation, or square-recognition behavior until their respective consuming specs are implemented.
- CN-SPEC-0015-FR015: Foundation APIs must avoid force unwraps, force casts, global mutable state, and hidden singleton dependencies.
- CN-SPEC-0015-FR016: Diagnostic descriptions may identify invalid bundled records or generator reasons but must not log user-entered answers, local history content, file paths containing personal information, or secrets.
- CN-SPEC-0015-FR017: Performance verification must cover index construction, repeated challenge generation, and stable memory behavior with thresholds intended to detect regressions rather than benchmark specific hardware.

## Acceptance Criteria

- CN-SPEC-0015-AC001: Given identical eligible fixtures, configuration, and seed, when two generators produce ten challenges, then their challenge identities and order are identical.
- CN-SPEC-0015-AC002: Given at least two eligible challenges, when the generator advances, then it does not return the same challenge twice consecutively.
- CN-SPEC-0015-AC003: Given a shuffled bag of N eligible items, when N challenges are requested, then each eligible identity appears exactly once before a new cycle starts.
- CN-SPEC-0015-AC004: Given only one eligible challenge, when multiple prompts are requested, then generation succeeds with that challenge and does not loop or report a false duplicate-avoidance failure.
- CN-SPEC-0015-AC005: Given no eligible challenge after filtering, when generation is requested, then a typed unavailable result identifies the reason and the app remains usable.
- CN-SPEC-0015-AC006: Given malformed candidate records mixed with valid records, when an index is built, then invalid candidates are excluded or reported while valid candidates remain usable.
- CN-SPEC-0015-AC007: Given a generator whose candidate-selection strategy repeatedly rejects candidates, when the attempt bound is reached, then generation returns a defined fallback or failure without additional attempts.
- CN-SPEC-0015-AC008: Given a session requests many prompts, when challenges are consumed, then only a bounded current/next working set is retained by the generator.
- CN-SPEC-0015-AC009: Given a screen starts a generation task and then starts a replacement session, when the old task completes, then its result cannot overwrite the replacement session.
- CN-SPEC-0015-AC010: Given existing notation, timed-notation, and square-recognition regression tests, when the foundation is introduced without mode adoption, then those tests continue to pass unchanged.
- CN-SPEC-0015-AC011: Given the bundled library index is already built, when subsequent prompts are requested, then the index is reused rather than reconstructed.
- CN-SPEC-0015-AC012: Given representative release fixtures, when performance checks run repeated index lookups and one thousand challenge selections, then the checks remain within documented regression budgets and allocate no unbounded retained session data.
- CN-SPEC-0015-AC013: Given a completed session configuration is encoded and decoded, when it is restored, then schema version, mode, difficulty, filters, timing metadata, and finish reason are preserved.
- CN-SPEC-0015-AC014: Given diagnostics are emitted for invalid source data, when their text is inspected, then it contains the technical reason but no entered answer, local history payload, secret, or personally identifying file path.

## Coverage

- Pending coverage: CN-SPEC-0015-AC001
- Pending coverage: CN-SPEC-0015-AC002
- Pending coverage: CN-SPEC-0015-AC003
- Pending coverage: CN-SPEC-0015-AC004
- Pending coverage: CN-SPEC-0015-AC005
- Pending coverage: CN-SPEC-0015-AC006
- Pending coverage: CN-SPEC-0015-AC007
- Pending coverage: CN-SPEC-0015-AC008
- Pending coverage: CN-SPEC-0015-AC009
- Pending coverage: CN-SPEC-0015-AC010
- Pending coverage: CN-SPEC-0015-AC011
- Pending coverage: CN-SPEC-0015-AC012
- Pending coverage: CN-SPEC-0015-AC013
- Pending coverage: CN-SPEC-0015-AC014

## Open Questions

- None. Consuming specs may add challenge kinds without weakening these determinism, safety, and performance contracts.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR1.