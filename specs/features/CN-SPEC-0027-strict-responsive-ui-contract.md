# CN-SPEC-0027: Strict Responsive UI Contract

Status: Proposed
Owner: Project
Last updated: 2026-07-15

## Intent

Turn Home and game-family layout requirements into measurable rendering rules. A layout is not accepted because source constants look reasonable; it is accepted only when rendered frames, safe-area placement, hierarchy, and typography satisfy this contract on representative devices.

## Scope

In scope:

- Home family-card geometry, spacing, safe-area placement, typography, and hierarchy.
- Board Skills family-screen hierarchy, Quick Start placement, and drill-row geometry.
- Rendered-frame validation on representative iPhone and iPad sizes.
- Accessibility Dynamic Type fallback behavior.
- Structural regression checks that prevent rejected layout patterns from returning.

Out of scope:

- Game rules, scoring, persistence, timing, and answer validation.
- Artwork redesign or replacement.
- Navigation semantics owned by CN-SPEC-0026 beyond the layout constraints referenced here.
- Full visual redesign of unrelated setup, gameplay, results, history, settings, or instruction screens.

## Functional Requirements

- CN-SPEC-0027-FR001: Home must contain exactly four primary family cards in a complete 2x2 grid at normal Dynamic Type sizes.
- CN-SPEC-0027-FR002: All four Home family cards must use one shared vertical component and identical explicit normal-size geometry.
- CN-SPEC-0027-FR003: Home card widths and heights must match within one rendered point, with strictly positive row and column spacing and no intersections or touching frames.
- CN-SPEC-0027-FR004: Home family cards must use matching artwork, title, subtitle, padding, corner radius, border, typography, and action-indicator regions.
- CN-SPEC-0027-FR005: Long horizontal family cards and partial gameplay rows are prohibited.
- CN-SPEC-0027-FR006: Home content must use a bounded centered width on iPad so cards remain proportionate.
- CN-SPEC-0027-FR007: At accessibility Dynamic Type sizes, the Home family grid must change to one column and allow unrestricted vertical text growth.
- CN-SPEC-0027-FR008: Hero content must begin below the navigation and status safe area, and Settings must use a navigation toolbar item rather than a floating overlay.
- CN-SPEC-0027-FR009: The only primary Home families are Notation Training, Timed Training, Board Skills, and Position Recall.
- CN-SPEC-0027-FR010: Instructions, Settings, History, and other utilities must not use the primary family-card component or appear inside the gameplay grid.
- CN-SPEC-0027-FR011: Square Recognition and Piece Movement must be presented under Board Skills rather than as direct Home cards.
- CN-SPEC-0027-FR012: A family screen must present a family summary, one prominent Quick Start action, a labeled game-choice section, compact aligned game rows or cards, and secondary actions below.
- CN-SPEC-0027-FR013: Board Skills Quick Start must launch the recommended Square Recognition setup.
- CN-SPEC-0027-FR014: Board Skills must present Square Recognition and Piece Movement as two compact rows with equal width, aligned leading edges, positive spacing, and no intersection.
- CN-SPEC-0027-FR015: Board Skills must not reuse the Home family-card grid for its drill choices.
- CN-SPEC-0027-FR016: Home and family-screen typography must use shared semantic fonts without per-card scaling exceptions.
- CN-SPEC-0027-FR017: Every Home or family-screen layout change must be validated on the required device matrix before being described as complete.

## Required Device Matrix

Every Home or family-screen layout change must be visually and automatically validated on:

- compact iPhone width, represented by iPhone SE-class devices;
- standard iPhone width, represented by iPhone 16-class devices;
- large iPhone width, represented by Pro Max-class devices;
- regular-width iPad portrait;
- regular-width iPad landscape;
- at least one accessibility Dynamic Type size.

A source-only test does not satisfy the device matrix.

## Home Geometry Contract

At normal Dynamic Type sizes:

- Home contains exactly four primary family cards in a complete 2x2 grid.
- All four cards use the same component and the same explicit rendered height.
- Cards in the same rendered layout have equal width within one point and equal height within one point.
- Horizontal and vertical gaps are strictly positive.
- No card frames may intersect or touch.
- Artwork regions, title regions, subtitle regions, typography, internal padding, corner radius, border treatment, and action-indicator placement are identical.
- Long horizontal family cards are prohibited.
- Partial gameplay rows are prohibited.
- The primary grid is centered in a bounded content width on iPad.
- Normal-size titles use one line; subtitles use at most two lines. Copy must be edited to fit this budget rather than increasing one card independently.

At accessibility Dynamic Type sizes:

- The grid changes to one column.
- Text may grow vertically without fixed-height clipping.
- All primary actions remain reachable through vertical scrolling.

## Home Safe-Area Contract

- Hero content must begin below the navigation and status safe area.
- Settings must use a navigation toolbar item rather than an independently overlaid floating control.
- Hero text must remain fully visible and may not be clipped by the Dynamic Island, status bar, navigation bar, or simulator chrome.
- The hero uses an explicit bounded height and consistent horizontal alignment with the sections below it.

## Home Hierarchy Contract

The only primary family cards are:

1. Notation Training
2. Timed Training
3. Board Skills
4. Position Recall

Instructions, Settings, History, and other utilities must not use the primary family-card component or appear inside the 2x2 gameplay grid.

Square Recognition and Piece Movement belong to Board Skills and are not direct Home cards.

## Family-Screen Contract

A family screen must not repeat the Home family-card grid by default.

Each family screen must use this hierarchy:

1. family title and concise purpose;
2. one visually prominent Quick Start action;
3. a labeled game-choice section;
4. compact, consistently aligned game rows or cards;
5. secondary history, setup, or help actions below the primary choices.

For Board Skills specifically:

- Quick Start launches the recommended Square Recognition setup.
- Square Recognition and Piece Movement appear as two compact rows of equal width and aligned leading edges.
- The two rows must have a positive vertical gap and may not intersect.
- Board Skills must not use `HomeMenuTile` or `LazyVGrid` for its two drill choices.

## Typography Contract

- Home family titles use the same semantic font and weight.
- Home family subtitles use the same semantic font, line limit, and text region.
- Family-screen Quick Start and game rows use semantic fonts and do not shrink text with `minimumScaleFactor`.
- Copy changes are preferred over per-card typography exceptions.

## Acceptance Criteria

- CN-SPEC-0027-AC001: Given normal Dynamic Type on a compact iPhone, when Home renders, then exactly four family cards form a complete 2x2 grid with equal width and height within one point.
- CN-SPEC-0027-AC002: Given Home on supported widths, when card frames are inspected, then horizontal and vertical gaps are positive and no card pair intersects or touches.
- CN-SPEC-0027-AC003: Given Home on iPad portrait and landscape, when the family grid renders, then it remains centered within a bounded width and cards do not become disproportionately wide.
- CN-SPEC-0027-AC004: Given Home at accessibility Dynamic Type, when the grid renders, then it uses one column, text is not clipped, and all actions remain reachable by vertical scrolling.
- CN-SPEC-0027-AC005: Given the production Home hierarchy, when primary and utility destinations are enumerated, then only the four documented families use family cards and Instructions remains secondary.
- CN-SPEC-0027-AC006: Given Home below the navigation bar, when the hero renders, then its text and artwork remain fully below the safe area without clipping or overlap.
- CN-SPEC-0027-AC007: Given Board Skills, when the screen renders, then Quick Start appears above Square Recognition and Piece Movement.
- CN-SPEC-0027-AC008: Given Board Skills, when drill-row frames are inspected, then the rows have equal width, aligned leading edges, positive spacing, and no intersection.
- CN-SPEC-0027-AC009: Given Board Skills source structure, when audited, then drill choices do not reuse the Home family-card grid.
- CN-SPEC-0027-AC010: Given the required device matrix, when validation is reported complete, then every listed device and Dynamic Type case has either passed or is explicitly recorded as unrun.

## Coverage

- `ChessNotationUITests/HomeUITests.swift`: CN-SPEC-0027-AC001, AC002, AC005, AC006, AC007, AC008.
- `ChessNotationTests/HomeTileLayoutRegressionTests.swift`: CN-SPEC-0027-AC001, AC004, AC005, AC009 structural guardrails.
- Manual simulator screenshots for iPhone SE-class, iPhone 16-class, Pro Max-class, iPad portrait, iPad landscape, and accessibility Dynamic Type: CN-SPEC-0027-AC003, AC004, AC006, AC010.
- `ChessNotation/Features/Home/RestoredHomeView.swift`: production owner for the Home and Board Skills layouts covered by this contract.

## Review Gate

A Home or family-screen UI change must not be described as complete until:

1. source-level regression tests pass;
2. rendered-frame UI tests pass on a standard iPhone;
3. visual screenshots are reviewed for the full required device matrix;
4. any unrun device or Dynamic Type case is explicitly listed;
5. CN-SPEC-0026 and this contract remain synchronized with implementation.

## Open Questions

- Whether future family screens should share a reusable compact row component or use family-specific row content while preserving the same geometry contract.
- Whether screenshot regression tooling should be added to CI after the current device-matrix process is stable.
- Whether CN-SPEC-0027 should remain a separate layout contract or be merged into CN-SPEC-0026 after CN-SPEC-0026 is accepted.

## Revision Notes

- 2026-07-15: Added after repeated Home revisions passed source-level checks while still producing clipped hero content, unbalanced card composition, and inappropriate tile-grid reuse on Board Skills. Established rendered-frame assertions, a required device matrix, safe-area rules, and family-screen hierarchy requirements.
- 2026-07-15: Converted the companion document into a complete CN-SPEC-0027 schema so repository spec validation can enforce title, scope, functional requirements, acceptance criteria, coverage, and open questions.
