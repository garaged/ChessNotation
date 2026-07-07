# CN-SPEC-0021: Training Insights and Library

Status: Proposed
Owner: Project
Last updated: 2026-07-07

## Intent

Make the game library and local history actively guide useful practice by exposing eligible challenge counts, favorites, recent-play controls, resumable games, personal bests, weak-skill summaries, and deterministic local recommendations.

## Scope

In scope:

- Favorites, recent-game exclusion, resume-last-game, challenge-count previews, richer filters, and surprise-me configuration.
- Local aggregation of weak categories, slow categories, missed squares, orientation performance, difficulty performance, streaks, and personal bests.
- One transparent next-practice recommendation.
- History reset, compaction/capping, migration, and robust library-data validation.

Out of scope:

- Cloud sync, accounts, social comparison, AI services, remote recommendations, or telemetry.
- Runtime engine analysis.
- Import/export of untrusted external game packs unless separately specified.

## Functional Requirements

- CN-SPEC-0021-FR001: Players must be able to mark and unmark bundled games as favorites using stable game identifiers.
- CN-SPEC-0021-FR002: The library must support excluding recently played games over a documented bounded recent window while falling back safely when exclusion would remove all candidates.
- CN-SPEC-0021-FR003: An unfinished full-game notation session must be resumable from its last unresolved move with configuration and progress preserved.
- CN-SPEC-0021-FR004: Library/session setup must show an eligible challenge count for the current mode and filters using the shared immutable index.
- CN-SPEC-0021-FR005: Filters must support existing level/opening/search behavior plus move tag, game length, and derivable phase where reliable data exists.
- CN-SPEC-0021-FR006: Surprise me must create a valid explicit session configuration from currently eligible modes and content; the chosen configuration must be visible before or at session start.
- CN-SPEC-0021-FR007: Local insights must aggregate weakest accuracy categories, slowest categories, frequently missed squares, board-orientation differences, difficulty performance, best streak, and personal best per compatible timed variant where sufficient data exists.
- CN-SPEC-0021-FR008: Aggregation windows and minimum sample sizes must be documented, deterministic, and shown with enough context to avoid presenting one attempt as a meaningful trend.
- CN-SPEC-0021-FR009: The home screen may show at most one primary next-practice recommendation derived from local history and eligible content.
- CN-SPEC-0021-FR010: A recommendation must state the supporting metric in user-readable form and must provide a direct route to a matching session configuration.
- CN-SPEC-0021-FR011: When history is insufficient or no matching challenges are eligible, the recommendation must use a documented general-practice fallback rather than fabricate weakness.
- CN-SPEC-0021-FR012: Insight and recommendation calculations must be pure/testable, must not depend on wall-clock globals, and must not execute expensive full-history transformations repeatedly from SwiftUI view bodies.
- CN-SPEC-0021-FR013: History storage must support reset by game type and reset-all with destructive confirmation and predictable failure reporting.
- CN-SPEC-0021-FR014: History growth must be bounded by a documented retention or compaction policy that preserves recent detail and lifetime aggregate/personal-best information required by the product.
- CN-SPEC-0021-FR015: Favorites, resume state, recommendations, and history migrations must tolerate unknown/deleted game IDs without crashing.
- CN-SPEC-0021-FR016: Every bundled game must pass validation for unique stable ID, non-empty moves, coordinate shape, usable `fenBefore`, source/destination squares, non-empty SAN, supported tags, and internally consistent evaluation data where present.
- CN-SPEC-0021-FR017: Invalid bundled records must be isolated and diagnosable while valid games remain available; release validation must fail for production-bundled invalid data.
- CN-SPEC-0021-FR018: All data and insight processing must remain local and must not add networking, analytics, tracking identifiers, or permissions.
- CN-SPEC-0021-FR019: Library and insight UI must support Dynamic Type, VoiceOver, keyboard navigation where applicable, and non-color-only selection/status indicators.

## Acceptance Criteria

- CN-SPEC-0021-AC001: Given a game is favorited and the app relaunches, when the library loads, then its favorite state is preserved by stable game ID.
- CN-SPEC-0021-AC002: Given recent exclusion removes some but not all eligible games, when random selection occurs, then excluded games are not selected; given it removes all, then the documented fallback restores an eligible pool.
- CN-SPEC-0021-AC003: Given an unfinished full game, when resume is selected after relaunch, then the same game, mode configuration, completed records, and next unresolved move are restored.
- CN-SPEC-0021-AC004: Given filters change, when eligible-count preview updates, then it matches the actual candidate set used by generation and does not rebuild the library index.
- CN-SPEC-0021-AC005: Given surprise me and a deterministic seed, when invoked, then it produces a valid visible configuration whose first challenge is eligible under that configuration.
- CN-SPEC-0021-AC006: Given sufficient history with one materially weaker category, when insights are calculated, then that category and its sample size/metric are reported deterministically.
- CN-SPEC-0021-AC007: Given insufficient samples, when insights render, then no unsupported weak-skill claim is shown.
- CN-SPEC-0021-AC008: Given a valid weak category with eligible content, when the recommendation is opened, then a matching preconfigured session is produced.
- CN-SPEC-0021-AC009: Given the recommended category has no eligible content, when recommendations are calculated, then a documented general-practice fallback is used.
- CN-SPEC-0021-AC010: Given multiple timed variants, when personal bests are calculated, then incompatible score/time definitions are not compared as one leaderboard.
- CN-SPEC-0021-AC011: Given reset-one-mode is confirmed, when persistence succeeds, then only that mode's detailed history and dependent aggregates are removed; reset-all removes all training history but not unrelated settings unless stated.
- CN-SPEC-0021-AC012: Given history exceeds the retention threshold, when compaction runs, then recent detailed records remain, required lifetime aggregates remain accurate, and storage growth is bounded.
- CN-SPEC-0021-AC013: Given favorites or resume state references a missing game, when loaded, then stale references are ignored or cleaned without blocking the library.
- CN-SPEC-0021-AC014: Given all bundled production games, when validation runs, then every game passes every required invariant and duplicate IDs are rejected.
- CN-SPEC-0021-AC015: Given a fixture containing one invalid and one valid game, when development loading runs, then the invalid record is reported and the valid record remains usable.
- CN-SPEC-0021-AC016: Given library and insight screens under large Dynamic Type and VoiceOver, when navigated, then primary content, controls, counts, statuses, and recommendation evidence remain understandable.
- CN-SPEC-0021-AC017: Given insight refresh with unchanged history, when measured repeatedly, then cached/derived data is reused and no networking or telemetry request occurs.

## Coverage

- Pending coverage: CN-SPEC-0021-AC001
- Pending coverage: CN-SPEC-0021-AC002
- Pending coverage: CN-SPEC-0021-AC003
- Pending coverage: CN-SPEC-0021-AC004
- Pending coverage: CN-SPEC-0021-AC005
- Pending coverage: CN-SPEC-0021-AC006
- Pending coverage: CN-SPEC-0021-AC007
- Pending coverage: CN-SPEC-0021-AC008
- Pending coverage: CN-SPEC-0021-AC009
- Pending coverage: CN-SPEC-0021-AC010
- Pending coverage: CN-SPEC-0021-AC011
- Pending coverage: CN-SPEC-0021-AC012
- Pending coverage: CN-SPEC-0021-AC013
- Pending coverage: CN-SPEC-0021-AC014
- Pending coverage: CN-SPEC-0021-AC015
- Pending coverage: CN-SPEC-0021-AC016
- Pending coverage: CN-SPEC-0021-AC017

## Open Questions

- None. Retention thresholds and minimum sample counts must be selected during implementation review and encoded as tested policy values.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR7.