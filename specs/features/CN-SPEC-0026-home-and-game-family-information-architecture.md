# CN-SPEC-0026: Home and Game-Family Information Architecture

Status: Accepted
Owner: Project
Last updated: 2026-08-23

## Intent

Keep the ChessNotation home screen focused, premium, and easy to scan while recovering a larger variety of playable games. The home screen must present a small number of stable training families rather than one tile per game. Each family screen must make quick start obvious, expose its full set of games without crowding, and preserve a clear path back to Home.

## Context

CN-SPEC-0023 defines the internal game catalog and route boundary. CN-SPEC-0024 and CN-SPEC-0025 define the recovered notation, timed, board-skill, and recall games. This spec defines how those catalog entries are grouped and presented to players.

The catalog is an internal source of truth, not a mandate to render every game as a top-level tile.

## Scope

In scope:

- Exactly four primary gameplay families on the home screen.
- Family screens for Notation Training, Timed Training, Board Skills, and Position Recall.
- Quick Start, game selection, last-used configuration, setup entry, recent-result summary, and family-level history access.
- Placement of Settings, History/Insights, and Instructions outside the primary gameplay grid.
- Stable ordering, adaptive layout, accessibility, navigation behavior, and regression constraints.
- Rules preventing future catalog entries from automatically becoming additional home tiles.
- Explicit visual symmetry, equal card geometry, collision prevention, and responsive behavior on common iPhone and iPad sizes.

Out of scope:

- Game rules, scoring, timing, answer validation, and result content owned by CN-SPEC-0024 and CN-SPEC-0025.
- A bottom-tab or legacy lower-menu restoration.
- Runtime engine analysis, networking, accounts, or online competition.
- Replacing the current premium design system or artwork pipeline.

## Home Information Architecture

The primary gameplay grid must contain exactly these four families in this order:

1. Notation Training
2. Timed Training
3. Board Skills
4. Position Recall

The home screen may also contain a hero, compact progress summary, recent activity, or secondary utility actions, but those must not visually compete with the four gameplay families.

Settings, History/Insights, and Instructions are secondary destinations:

- Settings remains available through the existing settings control.
- History/Insights may be shown as a compact secondary action or summary card, not as a fifth primary game tile.
- Instructions/Help must be available through a secondary action, toolbar item, settings/help area, or family-specific help link, not as a primary gameplay tile.

### Home visual contract

- The four primary family cards must render in one shared card component with identical width, height, artwork region, title region, subtitle region, padding, corner radius, typography hierarchy, border treatment, and action-indicator placement at normal Dynamic Type sizes.
- Compact-width layouts must use a two-column, two-row family grid. They must not replace family cards with long horizontal rows.
- Regular-width layouts must preserve the same two-by-two family geometry inside a centered maximum content width so cards do not become excessively wide on iPad.
- Accessibility Dynamic Type sizes may switch to one column and grow vertically, but all family cards must still use the same component and styling.
- No card may overlap, touch, clip into, or visually intrude into another card. Grid spacing must remain explicit and positive in both axes.
- Card copy must fit within documented title and subtitle line budgets at normal Dynamic Type sizes. Truncation may not hide the family name.
- Partial gameplay rows are forbidden on Home. A playable subgame belongs inside its owning family screen rather than becoming an unmatched top-level tile.

## Family Membership

### Notation Training

- Full Game
- Random Positions
- Focused Drill
- Opening Drill
- Mistake Review
- SAN Builder

### Timed Training

- Classic Timed
- Sprint
- Accuracy Race
- Survival
- Combo

### Board Skills

- Square Recognition quick start
- Expanded Square Recognition drills
- Piece Movement

### Position Recall

- Locate Piece
- Square Occupant
- Occupied Squares
- Reconstruction

A game must belong to exactly one primary family unless an explicit future spec defines a cross-family discovery surface. Internal engine reuse must not produce duplicate player-facing entries.

Current-release interpretation: entries whose domain rules exist but whose player-facing game screen is not surfaced in `3.0.1` remain discoverable inside their owning family as unavailable rows with an accessible reason and recovery action. This preserves family membership and avoids adding incomplete gameplay routes.

## Family Screen Contract

Every family screen must provide:

- A clear family title and concise explanation of its training purpose.
- A prominent Quick Start action using a documented compatible preset.
- A list or compact card group for all games in the family.
- A concise explanation of how each game differs.
- Last-used or recommended configuration where meaningful.
- An explicit Configure or Change Setup path when the selected game supports configuration.
- Access to family-relevant history or recent results without forcing a return to Home.
- A stable Back path to Home.
- Loading, ready, unavailable, and error states that never render an empty screen.

Quick Start must never silently choose an advanced or destructive configuration. It must use the current compatible default or the last successfully completed configuration when the player has explicitly opted into last-used behavior.

## Functional Requirements

- CN-SPEC-0026-FR001: The home primary gameplay grid must contain exactly four family tiles: Notation Training, Timed Training, Board Skills, and Position Recall.
- CN-SPEC-0026-FR002: Adding a game to the internal catalog must not automatically add a home tile.
- CN-SPEC-0026-FR003: Each playable catalog entry covered by CN-SPEC-0024 or CN-SPEC-0025 must be reachable through exactly one family screen.
- CN-SPEC-0026-FR004: Family membership and ordering must be declared in typed catalog or presentation metadata and validated outside SwiftUI view bodies.
- CN-SPEC-0026-FR005: The home view must render family metadata only and must not construct individual game engines or parse bundled game content.
- CN-SPEC-0026-FR006: Notation Training Quick Start must preserve the current full-game library path.
- CN-SPEC-0026-FR007: Timed Training Quick Start must preserve the current classic duration-based timed path.
- CN-SPEC-0026-FR008: Board Skills Quick Start must preserve the current Square Recognition coordinate-tap preset.
- CN-SPEC-0026-FR009: Position Recall Quick Start must preserve the current beginner reconstruction preset.
- CN-SPEC-0026-FR010: Family screens must distinguish Quick Start from selecting a different game or changing setup.
- CN-SPEC-0026-FR011: Returning from a completed game must return to that game’s family results or family screen according to the completion contract, not strand the player in a dead-end navigation state.
- CN-SPEC-0026-FR012: Selecting Play Again from results must relaunch the same game configuration without navigating through Home.
- CN-SPEC-0026-FR013: Selecting Change Setup from results must return to the relevant family setup with the completed configuration preselected.
- CN-SPEC-0026-FR014: Selecting Done or Back to Games from results must return to the owning family screen.
- CN-SPEC-0026-FR015: Family screens must preserve selection and scroll position when returning from setup or a completed game where platform navigation permits it.
- CN-SPEC-0026-FR016: Unavailable games must remain discoverable when useful, show a precise unavailable reason, and offer a valid alternative or configuration change; they must not navigate to an empty game screen.
- CN-SPEC-0026-FR017: Settings, History/Insights, and Instructions must not appear as equal-weight tiles in the primary gameplay grid.
- CN-SPEC-0026-FR018: The four family tiles must reuse current premium artwork, gradients, typography, spacing, fallback assets, and adaptive layout conventions.
- CN-SPEC-0026-FR019: Compact-width layouts must remain scannable without horizontal scrolling; regular-width layouts may use a wider grid while preserving family order.
- CN-SPEC-0026-FR020: VoiceOver must announce each family’s name, purpose, Quick Start behavior, and availability without enumerating hidden or unavailable implementation details.
- CN-SPEC-0026-FR021: Existing home accessibility identifiers must receive compatibility mappings where their destination changes from a direct game to a family screen.
- CN-SPEC-0026-FR022: Deep links or external routes targeting an existing direct game must continue to resolve directly or through a documented compatible setup without forcing the user through Home.
- CN-SPEC-0026-FR023: Family screens must not duplicate game scoring, lifecycle, validation, persistence, or timing rules.
- CN-SPEC-0026-FR024: A future fifth home family requires an explicit accepted information-architecture spec; catalog growth alone is insufficient.
- CN-SPEC-0026-FR025: The four Home family cards must use one shared vertical card component and identical normal-size geometry; horizontal family-card variants are prohibited.
- CN-SPEC-0026-FR026: Home must render the four family cards as a complete two-column by two-row grid on compact and regular width devices, except at accessibility Dynamic Type sizes where one-column vertical expansion is permitted.
- CN-SPEC-0026-FR027: The Home family grid must use explicit horizontal and vertical spacing and a bounded maximum content width so cards never collide and remain proportionate on iPad.
- CN-SPEC-0026-FR028: Square Recognition and Piece Movement must be presented inside Board Skills, while Instructions remains outside the gameplay grid.

## Acceptance Criteria

- CN-SPEC-0026-AC001: Given the production home screen, when its primary gameplay entries are enumerated, then exactly four family tiles appear in the documented order.
- CN-SPEC-0026-AC002: Given all recovered games, when family membership is validated, then every game appears exactly once and no duplicate or orphan entry exists.
- CN-SPEC-0026-AC003: Given a new catalog game without explicit family metadata, when catalog validation runs, then production discovery validation fails with a precise diagnostic rather than creating a new home tile.
- CN-SPEC-0026-AC004: Given each family Quick Start, when launched, then it resolves to the documented compatible current preset.
- CN-SPEC-0026-AC005: Given a family screen, when the player reviews its entries, then every game has a distinct purpose description and a launch or unavailable action.
- CN-SPEC-0026-AC006: Given a completed game, when Play Again is selected, then the same effective configuration starts with fresh session state and without returning to Home.
- CN-SPEC-0026-AC007: Given a completed configurable game, when Change Setup is selected, then the owning family setup opens with the previous effective configuration represented.
- CN-SPEC-0026-AC008: Given a completed game, when Done or Back to Games is selected, then the owning family screen becomes active and remains usable.
- CN-SPEC-0026-AC009: Given an unavailable family game, when selected, then a precise accessible explanation and at least one valid recovery action are shown without an empty push or crash.
- CN-SPEC-0026-AC010: Given compact and regular width devices, when Home and all family screens render, then no primary controls are clipped, horizontal scrolling is not required, and family ordering is stable.
- CN-SPEC-0026-AC011: Given VoiceOver, when Home and a family screen are traversed, then family names, purposes, Quick Start effects, game choices, unavailable reasons, and navigation actions are understandable.
- CN-SPEC-0026-AC012: Given existing direct-game deep links and accessibility identifiers, when the new hierarchy is introduced, then they resolve through explicit compatibility mappings and existing regression tests remain valid or receive intentional equivalent assertions.
- CN-SPEC-0026-AC013: Given repeated SwiftUI rendering of Home and family screens, when state updates occur, then no game engine construction, FEN/SAN parsing, bundled-library indexing, or history loading is triggered solely by tile metadata rendering.
- CN-SPEC-0026-AC014: Given a proposed fifth primary family or direct game tile, when presentation validation runs without an accepted superseding spec, then the configuration is rejected.
- CN-SPEC-0026-AC015: Given normal Dynamic Type on a compact iPhone and regular-width iPad, when the four Home family cards render, then all four have equal measured width and height, matching artwork/title/subtitle regions, matching typography, and matching action-indicator placement.
- CN-SPEC-0026-AC016: Given the Home family grid at supported widths, when card frames are inspected, then each row and column preserves the configured positive spacing and no pair of cards intersects or touches.
- CN-SPEC-0026-AC017: Given the production Home hierarchy, when gameplay and utility destinations are enumerated, then Square Recognition and Piece Movement appear only under Board Skills and Instructions appears only as a secondary Help action.

## Coverage

- `ChessNotation/Domain/GameFamilyCatalog.swift`: typed family metadata, family ordering, quick-start presets, playable and unavailable entries; CN-SPEC-0026-AC001, CN-SPEC-0026-AC002, CN-SPEC-0026-AC003, CN-SPEC-0026-AC004, CN-SPEC-0026-AC005, CN-SPEC-0026-AC009, CN-SPEC-0026-AC013, CN-SPEC-0026-AC014, CN-SPEC-0026-AC017.
- `ChessNotation/Features/Home/RestoredHomeView.swift`: production Home and family screens, Quick Start routes, unavailable rows, secondary history links, and compatibility identifiers; CN-SPEC-0026-AC001, CN-SPEC-0026-AC004, CN-SPEC-0026-AC005, CN-SPEC-0026-AC009, CN-SPEC-0026-AC010, CN-SPEC-0026-AC011, CN-SPEC-0026-AC012, CN-SPEC-0026-AC013, CN-SPEC-0026-AC017.
- `ChessNotation/Features/Results/ResultsView.swift`: Play Again, Back to Games, Choose Another Game, and timed Change Setup controls; CN-SPEC-0026-AC006, CN-SPEC-0026-AC007, CN-SPEC-0026-AC008.
- `ChessNotation/Features/Game/GameTrainingView.swift`: same-configuration replay and timed Change Setup sheet relaunch; CN-SPEC-0026-AC006, CN-SPEC-0026-AC007, CN-SPEC-0026-AC008.
- `ChessNotation/Features/PieceMovement/PieceMovementFeature.swift`: mini-game Play Again and Back to Games result controls; CN-SPEC-0026-AC006, CN-SPEC-0026-AC008.
- `ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift`: recall Play Again and Back to Games result controls; CN-SPEC-0026-AC006, CN-SPEC-0026-AC008.
- `ChessNotationTests/GameFamilyCatalogTests.swift`: catalog order, one-family membership, quick-start presets, duplicate/orphan rejection; CN-SPEC-0026-AC001, CN-SPEC-0026-AC002, CN-SPEC-0026-AC003, CN-SPEC-0026-AC004, CN-SPEC-0026-AC014.
- `ChessNotationTests/HomeTileLayoutRegressionTests.swift`: source-level Home/family hierarchy and layout guardrails; CN-SPEC-0026-AC001, CN-SPEC-0026-AC010, CN-SPEC-0026-AC015, CN-SPEC-0026-AC016, CN-SPEC-0026-AC017.
- `ChessNotationUITests/HomeUITests.swift`: production family routing, Quick Start compatibility, unavailable entry visibility, Board Skills ownership, Position Recall family screen, and secondary history links; CN-SPEC-0026-AC001, CN-SPEC-0026-AC004, CN-SPEC-0026-AC005, CN-SPEC-0026-AC009, CN-SPEC-0026-AC010, CN-SPEC-0026-AC011, CN-SPEC-0026-AC012, CN-SPEC-0026-AC017.
- `ChessNotationUITests/GameplayUITests.swift`: notation Play Again replay and library navigation compatibility; CN-SPEC-0026-AC006, CN-SPEC-0026-AC008, CN-SPEC-0026-AC012.
- `ChessNotationUITests/TimedGameUITests.swift`: timed results, selected-duration evidence, and Change Setup returning to the completed configuration; CN-SPEC-0026-AC006, CN-SPEC-0026-AC007, CN-SPEC-0026-AC008.
- `docs/manual-testing/home-board-skills-responsive-validation.md`: rendered Home and Board Skills responsive evidence; CN-SPEC-0026-AC010, CN-SPEC-0026-AC015, CN-SPEC-0026-AC016, CN-SPEC-0026-AC017.

## Implementation Constraints

- Do not add a bottom-tab or restore the historical lower menu.
- Do not render one home tile per game.
- Do not place game construction logic in `RestoredHomeView`.
- Keep family metadata pure and independent of SwiftUI where practical.
- Reuse `PremiumDesign`, existing tile components, current art, and asset fallbacks.
- Preserve direct routes for tests, deep links, and compatible quick starts.
- Implement catalog/family validation tests before replacing current home navigation.
- Add family screens incrementally so current games remain launchable during implementation.
- Do not introduce horizontal Home family cards as a compact-width workaround.
- Do not treat equal minimum heights as symmetry; normal-size family cards must use equal explicit geometry.

## Implementation Sequence

1. Add failing family-membership, four-tile, ordering, and validation tests.
2. Add typed family metadata and compatibility mappings to the catalog boundary.
3. Add family route resolver tests and family-level view models.
4. Implement Notation Training and Timed Training family screens while preserving current quick starts.
5. Implement Board Skills and Position Recall family screens while preserving current quick starts.
6. Move History/Insights and Instructions to secondary navigation without removing access.
7. Add complete results-to-family navigation and replay UI tests.
8. Run spec check, home regression, deep-link, accessibility, asset, and all game-family suites.

## Open Questions

- Future specs may replace unavailable family rows with fully playable standalone screens for SAN Builder, timed variants, and non-reconstruction recall drills.
- Future specs may add richer family-level recent-result summaries beyond the current history links.

## Revision Notes

- 2026-07-10: Initial proposed information-architecture contract defining four stable home families and complete family-level navigation.
- 2026-07-15: Normalized current home tiles to a stable two-column compact-width grid with equal title, subtitle, artwork, and card regions while preserving unrestricted vertical expansion at accessibility Dynamic Type sizes.
- 2026-07-15: Replaced the rejected mixed horizontal-card layout with an explicit symmetric four-family 2x2 Home grid, moved Square Recognition and Piece Movement under Board Skills, retained Instructions as a secondary Help action, bounded iPad content width, and added measurable equal-geometry and collision-prevention requirements.
- 2026-08-23: Accepted after adding typed family catalog validation, family screens for all four Home families, Quick Start compatibility routes, unavailable-entry recovery rows for non-surfaced current-release variants, family history links, explicit result Back to Games actions, timed Change Setup, and automated/unit/UI coverage.
