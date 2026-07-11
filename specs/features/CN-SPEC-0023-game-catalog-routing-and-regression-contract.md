# CN-SPEC-0023: Game Catalog, Routing, and Regression Contract

Status: Proposed
Owner: Project
Last updated: 2026-07-10

## Intent

Make every supported training experience discoverable through one coherent, premium game catalog while preserving the feel, behavior, data, and test coverage of current games. Establish an intent-driven integration boundary so future games are added by declaring user intent and capabilities rather than wiring unrelated navigation directly into the home view.

## Historical Context

Commit `e423bb44c4d7ed82a17a6400d8617622e11ff79f` exposed Notation Training, Timed Notation, Square Recognition, and Instructions. Current `main` preserves those paths and adds Piece Movement and Position Recall. Recovery must not copy the historical home implementation or replace stronger current versions.

The missing-game problem is a reachability and configuration problem: several accepted engines exist but are not fully represented by production routes.

## Scope

In scope:

- A strongly typed catalog of user-launchable training experiences.
- Stable game identities, categories, presentation metadata, launch intents, and capability declarations.
- Home/catalog routing that preserves the current premium visual language.
- Compatibility rules for existing tiles, accessibility identifiers, history identifiers, and deep links.
- Regression tests proving current games remain unchanged unless a later spec explicitly extends them.
- Intent-to-test traceability for all recovered games.

Out of scope:

- Implementing notation drill variants, timed variants, SAN Builder, or expanded mini-game rules; those are owned by CN-SPEC-0024 and CN-SPEC-0025.
- Replacing `PremiumDesign`, current assets, or the board rendering system.
- Runtime engine analysis, networking, accounts, or shared leaderboards.

## Intent Model

Every catalog entry must declare:

- Stable identity.
- Primary player intent, such as practice SAN, build speed, learn coordinates, visualize movement, or recall positions.
- Category: full training, timed training, or mini-game.
- Launch kind: direct preset, configurable setup, library selection, or informational route.
- Required capabilities, such as bundled-game index, SAN validation, monotonic clock, board interaction, history store, or random source.
- Result/history kind.
- Availability state and recoverable reason when dependencies or content are unavailable.
- Presentation metadata using existing design tokens and assets.

The catalog must describe intent and capabilities only. It must not own game rules, scoring, parsing, timers, persistence implementations, or SwiftUI game state.

## Functional Requirements

- CN-SPEC-0023-FR001: Existing Notation Training, Timed Notation, Square Recognition, Piece Movement, Position Recall, and Instructions routes must remain available with equivalent titles, visual hierarchy, and user-understandable purpose.
- CN-SPEC-0023-FR002: Stable identifiers used by UI tests, history, and external routes must not change without an explicit compatibility mapping.
- CN-SPEC-0023-FR003: A typed catalog must be the source of truth for game discovery and route construction; `RestoredHomeView` must not accumulate game-specific construction logic.
- CN-SPEC-0023-FR004: Catalog entries must describe player intent and required capabilities without depending on concrete service implementations.
- CN-SPEC-0023-FR005: The app composition root must resolve catalog launch intents to concrete feature dependencies.
- CN-SPEC-0023-FR006: Existing direct-launch presets for Piece Movement and Position Recall must remain valid while setup-driven routes are introduced.
- CN-SPEC-0023-FR007: Unavailable content or failed dependency construction must produce a recoverable, accessible state instead of a crash, empty navigation push, or silent failure.
- CN-SPEC-0023-FR008: The catalog must support deterministic ordering and grouping so adding a game cannot unpredictably reshuffle existing entries.
- CN-SPEC-0023-FR009: Presentation must reuse `PremiumDesign`, `HomeMenuTile`, existing artwork/fallback behavior, and current adaptive layout conventions.
- CN-SPEC-0023-FR010: Existing games must not acquire new scoring, timing, attempt, hint, history, or progression behavior solely because they are catalog-driven.
- CN-SPEC-0023-FR011: Each new catalog entry must link its player intent to at least one acceptance criterion, one feature or domain owner, and one planned automated test.
- CN-SPEC-0023-FR012: Catalog validation must reject duplicate stable identities, duplicate external route names, missing required metadata, and unsupported launch/result combinations.
- CN-SPEC-0023-FR013: Catalog construction and route resolution must be deterministic and must not parse bundled games, FEN, or SAN from SwiftUI view bodies.
- CN-SPEC-0023-FR014: VoiceOver ordering, labels, hints, and identifiers must remain stable for existing entries and be explicit for recovered entries.

## Acceptance Criteria

- CN-SPEC-0023-AC001: Given the current production catalog, when entries are enumerated, then all six current routes and Instructions appear once in deterministic groups.
- CN-SPEC-0023-AC002: Given a duplicate game identity or external route name, when catalog validation runs, then it fails with a precise diagnostic.
- CN-SPEC-0023-AC003: Given every existing home tile, when launched through the catalog, then it resolves to the same current feature or a documented compatible setup preset.
- CN-SPEC-0023-AC004: Given Piece Movement and Position Recall default presets, when launched after catalog integration, then their current beginner configurations and recoverable unavailable states remain equivalent.
- CN-SPEC-0023-AC005: Given unavailable content or a dependency-construction failure, when a route is launched, then an accessible recovery screen is shown and the user can return without app failure.
- CN-SPEC-0023-AC006: Given a recovered game entry, when its metadata is inspected, then player intent, launch kind, required capabilities, result kind, and test trace are present.
- CN-SPEC-0023-AC007: Given current UI tests for home and existing games, when catalog integration is applied, then existing accessibility identifiers and navigation assertions continue to pass.
- CN-SPEC-0023-AC008: Given compact and regular width layouts, when the catalog renders, then the current adaptive tile behavior, premium styling, fallback assets, and readable hierarchy are preserved.
- CN-SPEC-0023-AC009: Given the catalog is rendered repeatedly, when SwiftUI recomputes the view, then no bundled library indexing, FEN parsing, SAN parsing, or history loading is triggered by catalog metadata construction.
- CN-SPEC-0023-AC010: Given a new catalog entry with an unsupported capability combination, when validation runs, then it is rejected before production navigation can expose it.

## Planned Coverage

- `ChessNotationTests/GameCatalogTests.swift`: CN-SPEC-0023-AC001, AC002, AC003, AC004, AC006, AC009, AC010.
- `ChessNotationTests/GameRouteResolverTests.swift`: CN-SPEC-0023-AC003, AC004, AC005.
- `ChessNotationUITests/HomeUITests.swift`: CN-SPEC-0023-AC003, AC007, AC008.
- `ChessNotationTests/PremiumAssetTests.swift`: CN-SPEC-0023-AC008.
- Planned source owners: `ChessNotation/Domain/GameCatalog.swift`, `ChessNotation/App/GameRouteResolver.swift`, and `ChessNotation/Features/Home/RestoredHomeView.swift`.

## Implementation Constraints

- Introduce no dependency on SwiftUI in the domain catalog model.
- Keep feature construction in the app/composition layer.
- Prefer an enum or closed typed route model over string dispatch.
- Preserve source compatibility for existing feature initializers where practical.
- Do not migrate history as part of catalog integration.
- Implement tests before replacing direct navigation wiring.

## Open Questions

- Whether Instructions remains a catalog entry with a non-game result kind or stays as adjacent informational navigation. The chosen representation must not mix it into scoring/history.

## Revision Notes

- 2026-07-10: Initial proposed recovery and regression contract based on comparison of `e423bb4` with `main`.
