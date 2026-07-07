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

- CN-SPEC-0017-FR001 through CN-SPEC-0017-FR015 remain as defined in the accepted roadmap.

## Acceptance Criteria

- CN-SPEC-0017-AC001 through CN-SPEC-0017-AC014 remain as defined in the accepted roadmap.

## Coverage

- `ChessNotationTests/TimedNotationVariantTests.swift`: CN-SPEC-0017-AC001 through CN-SPEC-0017-AC011
- `ChessNotationTests/TimedNotationCompatibilityTests.swift`: CN-SPEC-0017-AC012, CN-SPEC-0017-AC013
- `ChessNotationTests/TimedNotationResultTests.swift`: CN-SPEC-0017-AC014
- `ChessNotation/Domain/TimedNotationVariants.swift`: CN-SPEC-0017-AC001 through CN-SPEC-0017-AC011
- `ChessNotation/Services/TimedNotationCompatibility.swift`: CN-SPEC-0017-AC012, CN-SPEC-0017-AC013

## Open Questions

- Resolved: all variants default to continue-against-deadline; pause-while-inactive is explicit and shifts the deadline by the exact inactive interval.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR3.
- 2026-07-07: Implementation and simulator tests completed successfully on iPhone 17 / iOS 26.5; final archive/status cleanup remains a documentation-only follow-up.
