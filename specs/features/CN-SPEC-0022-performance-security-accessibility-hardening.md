# CN-SPEC-0022: Performance, Security, and Accessibility Hardening

Status: Proposed
Owner: Project
Last updated: 2026-07-15

## Intent

Establish measurable release criteria that keep the expanded training system responsive on older supported hardware, resilient to malformed local data, private by default, and usable through accessibility features.

## Scope

In scope:

- FEN and preview caching, immutable library indexes, timer/render efficiency, bounded memory, lifecycle cleanup, and performance regression checks.
- Atomic persistence, schema migration, corruption recovery, size limits, diagnostics redaction, and local-only privacy guarantees.
- Accessibility audit and tests covering VoiceOver, Dynamic Type, reduced motion, contrast, haptics, keyboard input, orientation, and non-color-only feedback.
- Release validation and documentation updates for PR1 through PR8.

Out of scope:

- Supporting devices below the app's deployment target.
- Penetration testing of remote services because no remote service is in scope.
- Cloud sync, user accounts, analytics, advertising, or telemetry.
- Visual redesign unrelated to accessibility or performance.

## Functional Requirements

- CN-SPEC-0022-FR001: Parsed FEN board states must be cached through a bounded policy keyed by stable position input and reused across repeated rendering and challenge generation.
- CN-SPEC-0022-FR002: Game-library decoding and challenge indexing must occur once per repository/content lifetime or explicit invalidation, not per screen render or prompt.
- CN-SPEC-0022-FR003: Thumbnail and preview generation must be lazy or cached and must not block an interactive transition by decoding the complete library synchronously.
- CN-SPEC-0022-FR004: Timer-driven state updates must update only required observable state and must not trigger FEN parsing, index construction, history aggregation, or challenge regeneration.
- CN-SPEC-0022-FR005: Long sessions must release resolved challenge-specific resources and maintain bounded retained memory.
- CN-SPEC-0022-FR006: Work owned by dismissed screens, replaced sessions, or inactive tasks must be cancelled or prevented from mutating live state.
- CN-SPEC-0022-FR007: Performance tests must cover initial library/index construction, cached lookups, one thousand challenge generations, repeated history aggregation, timer refresh behavior, and representative long-session memory stability.
- CN-SPEC-0022-FR008: Performance thresholds must compare against documented regression budgets with tolerance for CI variability and must not claim universal frame-rate guarantees from simulator timings.
- CN-SPEC-0022-FR009: History and settings writes must use atomic replacement or an equivalent strategy that does not leave a partially written primary file after interruption.
- CN-SPEC-0022-FR010: Persisted models must be schema-versioned, decode supported older versions, reject unsupported future/incompatible versions safely, and use explicit migrations/defaults.
- CN-SPEC-0022-FR011: Corrupt persistence must not crash launch or training completion; the app must isolate the corrupt payload, expose a safe recovery/reset path, and avoid silently overwriting recoverable evidence before the user acts where practical.
- CN-SPEC-0022-FR012: Persistence must bound accepted file size, record count, string length, and nested collection sizes where externally mutable local files could otherwise cause excessive memory or CPU use.
- CN-SPEC-0022-FR013: Bundled game decoding must reject malformed coordinates, invalid indexes, duplicate stable IDs, empty required strings, unsupported required schema, and internally inconsistent records without force unwraps or out-of-range access.
- CN-SPEC-0022-FR014: Diagnostics must be useful for development while redacting entered answers, local history payloads, personal file paths, secrets, tokens, certificates, and provisioning data.
- CN-SPEC-0022-FR015: The app must add no networking, tracking, analytics, advertising identifier use, account requirement, or unnecessary entitlement/permission as part of this roadmap.
- CN-SPEC-0022-FR016: Every primary training flow must expose stable accessibility identifiers for critical UI tests and meaningful VoiceOver labels, values, traits, focus order, and progress.
- CN-SPEC-0022-FR017: Board orientation and chess coordinates must remain understandable with VoiceOver and must map consistently under white and black orientation.
- CN-SPEC-0022-FR018: Correctness, warnings, selection, timer urgency, and disabled states must not be communicated by color alone.
- CN-SPEC-0022-FR019: Non-board layouts must support Dynamic Type without clipping critical controls or making completion/navigation impossible.
- CN-SPEC-0022-FR020: Animations must respect Reduce Motion; haptics and audio feedback must respect app/system settings and have equivalent visible or spoken feedback.
- CN-SPEC-0022-FR021: Keyboard-based answer flows and external-keyboard navigation must preserve existing behavior and receive regression coverage where supported.
- CN-SPEC-0022-FR022: Accessibility and performance changes must preserve existing visual themes, board assets, history compatibility, and accepted gameplay semantics unless a preceding active spec explicitly changes them.
- CN-SPEC-0022-FR023: Release documentation must state supported local data behavior, privacy posture, new modes, migration notes, known limits, and exact validation commands/results.
- CN-SPEC-0022-FR024: Implementation PRs must add regression tests for every fixed defect that is reproducible at unit, integration, or UI level.

## Acceptance Criteria

- CN-SPEC-0022-AC001: Given repeated requests for the same FEN, when parsed through the production boundary, then subsequent requests reuse the cached result and the cache remains within its configured bound.
- CN-SPEC-0022-AC002: Given navigation among library and training screens, when indexes and previews are requested repeatedly, then the library index is constructed once per content lifetime and preview work remains lazy/cached.
- CN-SPEC-0022-AC003: Given timer refreshes in a timed session, when instrumentation counts expensive operations, then no unchanged FEN parse, index rebuild, history recomputation, or challenge regeneration is caused by the refresh alone.
- CN-SPEC-0022-AC004: Given a representative long session, when it resolves many prompts, then retained challenge/resource counts remain bounded and dismissed session tasks cannot mutate the current session.
- CN-SPEC-0022-AC005: Given documented performance fixtures, when regression checks run, then each operation remains within its budget or reports a clear actionable failure without relying on one brittle absolute wall-clock assertion.
- CN-SPEC-0022-AC006: Given interruption during a simulated history write, when storage is reopened, then either the previous complete file or the new complete file is readable and no partial primary payload is treated as valid.
- CN-SPEC-0022-AC007: Given each supported historical schema fixture, when loaded, then required metrics and configuration are migrated or defaulted as documented.
- CN-SPEC-0022-AC008: Given corrupt, oversized, deeply nested, or unsupported-version history fixtures, when loaded, then processing terminates within defined bounds, the app remains usable, and a recovery/reset state is available.
- CN-SPEC-0022-AC009: Given malformed bundled game fixtures, when validated, then each invalid invariant is reported without crash or unsafe indexing and valid sibling records remain testable.
- CN-SPEC-0022-AC010: Given emitted diagnostics from source and persistence failures, when inspected, then they contain the category and safe identifier but no answer text, history payload, secret, or personal path.
- CN-SPEC-0022-AC011: Given the completed roadmap build, when entitlements, permissions, dependencies, and runtime traffic are inspected, then no new networking, tracking, analytics, account, or unnecessary permission surface exists.
- CN-SPEC-0022-AC012: Given VoiceOver in every primary game, when the user starts, answers, receives feedback, finishes, and opens results, then all critical actions and state are understandable and stable identifiers support UI coverage.
- CN-SPEC-0022-AC013: Given white and black board orientations, when VoiceOver focus and taps identify squares, then spoken coordinates and validation map to the same chess squares.
- CN-SPEC-0022-AC014: Given grayscale or an accessibility inspection, when correctness, urgency, selection, and disabled states render, then text, shape, symbol, or spoken cues communicate the state without color alone.
- CN-SPEC-0022-AC015: Given the largest supported Dynamic Type sizes, when core setup, gameplay, result, history, and settings screens render, then critical content can scroll and all primary actions remain reachable.
- CN-SPEC-0022-AC016: Given Reduce Motion and disabled haptics, when feedback and transitions occur, then disallowed effects do not run and equivalent visible/spoken feedback remains.
- CN-SPEC-0022-AC017: Given supported external-keyboard flows, when answers and navigation are exercised, then focus and submission remain correct without breaking the on-screen keyboard path.
- CN-SPEC-0022-AC018: Given all roadmap implementation PRs are ready, when release validation runs, then spec check, targeted tests, full unit/integration tests, critical UI tests, bundled-data validation, and documented performance checks pass or every unrun item is explicitly explained.
- CN-SPEC-0022-AC019: Given a reproducible defect fixed during implementation, when its PR is reviewed, then a regression test fails before the fix and passes with the fix whenever the behavior is testable.
- CN-SPEC-0022-AC020: Given release documentation review, when the roadmap ships, then README, privacy/release notes, change log, and relevant specs accurately describe local-only behavior, migrations, modes, validation, and known limitations.

## Policy Constants

- FEN board cache capacity: 256 distinct normalized FEN strings.
- `startpos` and the full standard starting-position FEN share one cache identity.
- Cache eviction policy: least recently used.
- Cache instrumentation is internal and exists for deterministic regression testing; production UI does not depend on cache metrics.
- Position Recall reconstruction history maximum file size: 2 MiB.
- Position Recall reconstruction history maximum record count: 5,000.
- Position Recall reconstruction history current schema version: 1.
- Legacy schema 0 is the unwrapped JSON result array and is migrated to the version-1 envelope on the next successful save.
- Future schema versions are rejected and preserved rather than decoded with guessed defaults.
- Corrupt or rejected Position Recall history is copied once to a sibling `.corrupt` evidence file and is not silently replaced by a later save.
- Position Recall history reset removes the primary payload only; preserved corrupt evidence remains available for diagnosis or manual recovery.
- Bundled game validation occurs after decoding and before results enter the shared cache.
- Duplicate game IDs are rejected across the complete configured resource set, not only within one JSON file.
- Chess coordinates must be lowercase algebraic squares from `a1` through `h8`; promotion coordinate suffixes remain valid when the coordinate begins with `from + to`.
- FEN validation requires exactly eight placement ranks, each expanding to exactly eight files, using only legal piece symbols or empty-run digits.
- Validation diagnostics expose issue category, game ID, move index, and field name only; they do not include full game records, SAN answers, titles, or file paths.
- Timer refresh instrumentation counts refresh calls and timeout transitions only; gameplay score, prompt progress, FEN cache metrics, and library cache metrics must remain unchanged during non-terminal refreshes.
- The timer refresh regression fixture uses 1,000 refreshes and avoids brittle wall-clock timing assertions.
- Long-session generation fixtures use 10,000 accepted prompts and 1,000 rejected/cancelled calls.
- A generator may retain only its immutable source plus the current shrinking shuffled cycle; retained-cycle count must remain below source count after generation begins.
- Rejected generation is bounded by the configured maximum-attempt count, and cancellation must prevent the shuffled bag from advancing.
- Performance regression budgets use deterministic operation counts, explicit tolerance, and actionable remediation instead of simulator wall-clock thresholds.
- The application target has no Swift Package product dependencies, third-party framework build entries, code-signing entitlements, sensitive usage-description keys, networking API markers, tracking APIs, analytics SDKs, advertising APIs, or account/authentication surfaces.
- The privacy audit scans production Swift sources and the Xcode project so future capability additions require an intentional policy update.
- Each mini-game board exposes one VoiceOver element per chess square with identifier `board.square.<coordinate>` and a label beginning with the actual algebraic coordinate.
- Board orientation changes display order only; it does not change square identity, accessibility identifier, spoken coordinate, or tap-to-coordinate mapping.
- Piece Movement spoken square state distinguishes source piece, friendly blocker, enemy piece, selected destination, and empty square without requiring color perception.
- Position Recall spoken square state distinguishes visible, masked, and reconstructed pieces across study, answer, and result phases.
- Primary mini-game completion and feedback states include text and stable accessibility identifiers; symbols and colors are supplementary.
- Dynamic Type reachability checks require primary flows to remain scrollable and prohibit explicit text-size caps, forced single-line critical content, minimum-scale shrinking, and fixed-height critical-action containers.

## Coverage

- `ChessNotation/Services/FENParser.swift`: CN-SPEC-0022-AC001, CN-SPEC-0022-AC003.
- `ChessNotationTests/FENCacheTests.swift`: CN-SPEC-0022-AC001.
- `ChessNotation/Features/PositionRecall/PositionRecallReconstructionHistoryStore.swift`: CN-SPEC-0022-AC006, CN-SPEC-0022-AC007, CN-SPEC-0022-AC008.
- `ChessNotationTests/PositionRecallHistoryStoreHardeningTests.swift`: CN-SPEC-0022-AC006, CN-SPEC-0022-AC008, CN-SPEC-0022-AC019.
- `ChessNotationTests/PositionRecallHistorySchemaTests.swift`: CN-SPEC-0022-AC007, CN-SPEC-0022-AC008, CN-SPEC-0022-AC019.
- `ChessNotation/Services/GameLibraryService.swift`: CN-SPEC-0022-AC002, CN-SPEC-0022-AC003, CN-SPEC-0022-AC009, CN-SPEC-0022-AC010.
- `ChessNotationTests/BundledGameValidationTests.swift`: CN-SPEC-0022-AC009, CN-SPEC-0022-AC010, CN-SPEC-0022-AC019.
- `ChessNotation/Domain/TimedNotationVariants.swift`: CN-SPEC-0022-AC003.
- `ChessNotationTests/TimerRefreshEfficiencyTests.swift`: CN-SPEC-0022-AC003, CN-SPEC-0022-AC019.
- `ChessNotation/Domain/TrainingChallenge.swift`: CN-SPEC-0022-AC004.
- `ChessNotationTests/LongSessionResourceBoundTests.swift`: CN-SPEC-0022-AC004.
- `ChessNotation/Domain/PerformanceRegressionBudget.swift`: CN-SPEC-0022-AC005.
- `ChessNotationTests/PerformanceRegressionBudgetTests.swift`: CN-SPEC-0022-AC005, CN-SPEC-0022-AC019.
- `ChessNotation.xcodeproj/project.pbxproj`: CN-SPEC-0022-AC011.
- `ChessNotationTests/PrivacySurfaceAuditTests.swift`: CN-SPEC-0022-AC011, CN-SPEC-0022-AC019.
- `ChessNotation/Features/Game/MiniGameBoardView.swift`: CN-SPEC-0022-AC012, CN-SPEC-0022-AC013.
- `ChessNotation/Features/PieceMovement/PieceMovementFeature.swift`: CN-SPEC-0022-AC012, CN-SPEC-0022-AC014.
- `ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift`: CN-SPEC-0022-AC012, CN-SPEC-0022-AC013, CN-SPEC-0022-AC014.
- `ChessNotationTests/BoardSquareAccessibilitySemanticsTests.swift`: CN-SPEC-0022-AC012, CN-SPEC-0022-AC013, CN-SPEC-0022-AC019.
- `ChessNotationTests/MiniGameStateAccessibilityTests.swift`: CN-SPEC-0022-AC012, CN-SPEC-0022-AC013, CN-SPEC-0022-AC014, CN-SPEC-0022-AC019.
- `ChessNotationTests/DynamicTypeReachabilityAuditTests.swift`: CN-SPEC-0022-AC015, CN-SPEC-0022-AC019.
- Pending coverage: CN-SPEC-0022-AC016
- Pending coverage: CN-SPEC-0022-AC017
- Pending coverage: CN-SPEC-0022-AC018
- Pending coverage: CN-SPEC-0022-AC020

## Open Questions

- None. Concrete cache limits, size limits, and performance budgets must be recorded as tested policy constants before this spec becomes Accepted.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR8.
- 2026-07-10: Began implementation with a bounded thread-safe LRU FEN board cache, deterministic cache metrics, and regression coverage for reuse, capacity, and recency.
- 2026-07-10: Hardened Position Recall reconstruction history with atomic bounded writes, corrupt-payload preservation, explicit reset, and regression coverage preventing silent data loss.
- 2026-07-15: Added semantic validation for bundled game IDs, required strings, move numbers, coordinates, coordinate consistency, and FEN placement, with redacted diagnostics and regression fixtures.
- 2026-07-15: Added version-1 Position Recall history envelopes, legacy array migration on save, and safe rejection/preservation of unsupported future schemas.
- 2026-07-15: Added timer-refresh and library-cache instrumentation with a 1,000-refresh regression proving timer ticks do not trigger FEN parsing, library decoding, score changes, prompt progress, or duplicate completion.
- 2026-07-15: Added bounded long-session generation and cancellation regression coverage using operation-count budgets instead of wall-clock assumptions.
- 2026-07-15: Added reusable deterministic performance budgets with tolerance and actionable diagnostics.
- 2026-07-15: Added a local-only privacy surface audit covering production source markers, package dependencies, linked frameworks, entitlements, and sensitive permission declarations.
- 2026-07-15: Added shared VoiceOver board-square semantics with stable `board.square.<coordinate>` identifiers and orientation-invariant coordinate mapping.
- 2026-07-15: Added mini-game state accessibility regression coverage for Piece Movement source/blocker/enemy/selected states and Position Recall visible/masked/reconstructed states.
- 2026-07-15: Added Dynamic Type reachability auditing for the primary Piece Movement and Position Recall flows, requiring scrollable containers and rejecting fixed-height or text-shrinking critical-action layouts.
