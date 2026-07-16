# CN-SPEC-0026 Companion: Strict Responsive UI Contract

Status: Proposed
Owner: Project
Last updated: 2026-07-15

## Intent

Turn Home and game-family layout requirements into measurable rendering rules. A layout is not accepted because source constants look reasonable; it is accepted only when rendered frames, safe-area placement, hierarchy, and typography satisfy this contract on representative devices.

## Required device matrix

Every Home or family-screen layout change must be visually and automatically validated on:

- compact iPhone width, represented by iPhone SE-class devices;
- standard iPhone width, represented by iPhone 16-class devices;
- large iPhone width, represented by Pro Max-class devices;
- regular-width iPad portrait;
- regular-width iPad landscape;
- at least one accessibility Dynamic Type size.

A source-only test does not satisfy the device matrix.

## Home geometry contract

At normal Dynamic Type sizes:

- Home contains exactly four primary family cards in a complete 2×2 grid.
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

## Home safe-area contract

- Hero content must begin below the navigation and status safe area.
- Settings must use a navigation toolbar item rather than an independently overlaid floating control.
- Hero text must remain fully visible and may not be clipped by the Dynamic Island, status bar, navigation bar, or simulator chrome.
- The hero uses an explicit bounded height and consistent horizontal alignment with the sections below it.

## Home hierarchy contract

The only primary family cards are:

1. Notation Training
2. Timed Training
3. Board Skills
4. Position Recall

Instructions, Settings, History, and other utilities must not use the primary family-card component or appear inside the 2×2 gameplay grid.

Square Recognition and Piece Movement belong to Board Skills and are not direct Home cards.

## Family-screen contract

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

## Typography contract

- Home family titles use the same semantic font and weight.
- Home family subtitles use the same semantic font, line limit, and text region.
- Family-screen Quick Start and game rows use semantic fonts and do not shrink text with `minimumScaleFactor`.
- Copy changes are preferred over per-card typography exceptions.

## Automated acceptance checks

`ChessNotationUITests/HomeUITests.swift` must verify rendered frames for:

- equal Home family-card width and height;
- positive first-row and second-row horizontal gaps;
- positive left-column and right-column vertical gaps;
- no pairwise card intersection;
- Board Skills Quick Start above both game rows;
- equal Board Skills game-row width and leading alignment;
- positive gap and no intersection between Board Skills rows.

`ChessNotationTests/HomeTileLayoutRegressionTests.swift` must verify structural guardrails for:

- exactly four family entries;
- one family-card component;
- explicit geometry constants;
- one-column accessibility fallback;
- toolbar-based Settings placement;
- absence of floating top-right overlay layout;
- Board Skills Quick Start plus compact game rows;
- absence of Home-sized tile grids in Board Skills.

## Review gate

A Home or family-screen UI change must not be described as complete until:

1. source-level regression tests pass;
2. rendered-frame UI tests pass on a standard iPhone;
3. visual screenshots are reviewed for the full required device matrix;
4. any unrun device or Dynamic Type case is explicitly listed;
5. CN-SPEC-0026 and this companion contract remain synchronized with implementation.

## Revision Notes

- 2026-07-15: Added after repeated Home revisions passed source-level checks while still producing clipped hero content, unbalanced card composition, and an inappropriate tile-grid reuse on Board Skills. Established rendered-frame assertions, a required device matrix, safe-area rules, and family-screen hierarchy requirements.
