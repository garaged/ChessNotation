# CN-SPEC-0021: Local Insights and Library Personalization

Status: Accepted
Owner: Project
Last updated: 2026-07-08

## Intent

Add local, transparent training insights and lightweight library preferences so ChessNotation can recommend useful practice without accounts, remote analytics, or opaque scoring.

## Scope

In scope:

- Local metric aggregation by training category.
- Weakest and slowest category insight calculation with minimum sample thresholds.
- One transparent practice recommendation with fallback behavior when history or matching content is insufficient.
- Favorite game IDs and bounded recent-game history.
- Recent-game exclusion with safe fallback when exclusion would remove all candidates.
- Product-facing presentation, persistence, and view-model surface for recommendations and library preferences.

Out of scope:

- Remote sync, accounts, cloud analytics, social leaderboards, or cross-device personalization.
- Opaque machine-learning recommendations.
- Engine-derived tactical recommendations.

## Functional Requirements

- CN-SPEC-0021-FR001: Metric samples must preserve category, correct count, total attempts, average latency, and derived accuracy.
- CN-SPEC-0021-FR002: Weakest-category calculation must ignore categories below a minimum sample threshold.
- CN-SPEC-0021-FR003: Weakest-category tie breaking must be deterministic: lower accuracy first, then slower average latency, then category name.
- CN-SPEC-0021-FR004: Slowest-category calculation must ignore categories below a minimum sample threshold.
- CN-SPEC-0021-FR005: Slowest-category tie breaking must be deterministic: slower average latency first, then lower accuracy, then category name.
- CN-SPEC-0021-FR006: Recommendations must expose the selected category, sample count, accuracy evidence, and whether a fallback was used.
- CN-SPEC-0021-FR007: Recommendations must fall back to general mixed practice when history is too sparse or matching practice content is unavailable.
- CN-SPEC-0021-FR008: Favorite game IDs must be addable, removable, Codable, and persisted locally.
- CN-SPEC-0021-FR009: Recent-game history must be unique, most-recent-first, bounded by a configured limit, and persisted locally.
- CN-SPEC-0021-FR010: Recent-game exclusion must skip recent games when alternatives exist and must safely fall back to all candidates when exclusion would remove everything.
- CN-SPEC-0021-FR011: All personalization data must remain local model state and must not require account, network, or remote analytics dependencies.
- CN-SPEC-0021-FR012: The product-facing insight surface must provide accessibility-ready summary text that includes recommendation, evidence, favorites, and recent history without requiring hidden analytics.

## Acceptance Criteria

- CN-SPEC-0021-AC001: Given categories with enough samples, when weakest category is calculated, then the lowest accuracy category is selected, with slower latency and category name used as stable tie breakers.
- CN-SPEC-0021-AC002: Given categories below the minimum sample threshold, when weakest or slowest insight is calculated, then no unsupported claim is produced for those categories.
- CN-SPEC-0021-AC003: Given categories with equal accuracy but different latency, when slowest category is calculated, then the slower eligible category is selected.
- CN-SPEC-0021-AC004: Given an eligible weak category with matching content, when recommendation is calculated, then it names the category and includes accuracy/sample evidence.
- CN-SPEC-0021-AC005: Given sparse history or no matching eligible content, when recommendation is calculated, then a general-practice fallback is returned and marked as fallback.
- CN-SPEC-0021-AC006: Given favorite game IDs, when favorites are added, removed, encoded, decoded, saved, and restored, then the resulting favorite set is preserved.
- CN-SPEC-0021-AC007: Given repeated recent games and a configured limit, when recent history is recorded, saved, and restored, then it stays unique, most-recent-first, and bounded.
- CN-SPEC-0021-AC008: Given recent-game exclusion, when non-recent candidates exist, then only non-recent candidates are returned.
- CN-SPEC-0021-AC009: Given recent-game exclusion would remove all candidates, when eligible games are requested, then all candidates are returned as a safe fallback.
- CN-SPEC-0021-AC010: Given the product-facing insight surface, when a recommendation is presented, then the selected category, evidence, fallback status, favorite IDs, recent IDs, and recommended game IDs are exposed for UI and accessibility.
- CN-SPEC-0021-AC011: Given favorites or recent games are changed from the view model, when presentation refreshes, then the locally persisted preferences and recommended game IDs reflect the change.

## Coverage

- `ChessNotationTests/TrainingInsightsTests.swift`: CN-SPEC-0021-AC001, CN-SPEC-0021-AC002, CN-SPEC-0021-AC003, CN-SPEC-0021-AC004, CN-SPEC-0021-AC005, CN-SPEC-0021-AC006, CN-SPEC-0021-AC007, CN-SPEC-0021-AC008, CN-SPEC-0021-AC009
- `ChessNotationTests/TrainingInsightsFeatureTests.swift`: CN-SPEC-0021-AC004, CN-SPEC-0021-AC005, CN-SPEC-0021-AC006, CN-SPEC-0021-AC007, CN-SPEC-0021-AC008, CN-SPEC-0021-AC009, CN-SPEC-0021-AC010, CN-SPEC-0021-AC011
- `ChessNotation/Domain/TrainingInsights.swift`: CN-SPEC-0021-AC001, CN-SPEC-0021-AC002, CN-SPEC-0021-AC003, CN-SPEC-0021-AC004, CN-SPEC-0021-AC005, CN-SPEC-0021-AC006, CN-SPEC-0021-AC007, CN-SPEC-0021-AC008, CN-SPEC-0021-AC009
- `ChessNotation/Features/Insights/TrainingInsightsFeature.swift`: CN-SPEC-0021-AC004, CN-SPEC-0021-AC005, CN-SPEC-0021-AC006, CN-SPEC-0021-AC007, CN-SPEC-0021-AC008, CN-SPEC-0021-AC009, CN-SPEC-0021-AC010, CN-SPEC-0021-AC011

## Open Questions

- None. Richer UI placement can build on this accepted product-facing foundation.

## Revision Notes

- 2026-07-08: Added proposed local insights and library personalization foundation after CN-SPEC-0017 through CN-SPEC-0020 were completed and accepted.
- 2026-07-08: Accepted after corrective simulator validation passed for `TrainingInsightsTests` and `make spec-check`.
- 2026-07-08: Expanded implementation with product-facing recommendation presentation, local preferences store, view-model refresh/persistence flow, and accessibility-ready summary coverage.
