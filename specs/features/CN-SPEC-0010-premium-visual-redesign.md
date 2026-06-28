# CN-SPEC-0010: Premium Visual Redesign

Status: Proposed
Owner: Project
Last updated: 2026-06-27

## Intent

ChessNotation should visually move much closer to the provided mock design while
preserving the app's current training flows. The redesigned app should feel like
a premium chess training tool: dark, cinematic, chess-specific, image-rich, and
clear about the next action.

The mock is the visual target, not a literal navigation requirement. The normal
app flow remains:

- Home selects a training mode.
- Game Library selects a notation game.
- Timed notation chooses a duration before play.
- Square Recognition uses its own setup flow.
- Instructions and Settings remain available from Home.

All app screens should feel like part of the same product after the redesign.
Implementation may add, remove, split, or combine screens when doing so makes the
training flow clearer, provided the behavior covered by existing specs remains
reachable and testable.

## Scope

In scope:

- Dark premium visual direction inspired by the mock.
- Home dashboard with image-forward mode tiles.
- Game Library screen with rich search, filter chips, game rows, random game
  entry, and launch-mode affordance.
- Premium styling for notation training, timed notation, timed results,
  square-recognition setup/play/results/history, instructions, and settings.
- Screen additions, removals, splits, or consolidations that improve the normal
  flow while preserving specified behavior.
- Bottom navigation visual treatment only if it does not imply unavailable
  sections.
- Shared visual hierarchy, typography, spacing, color, surfaces, buttons,
  cards, rows, controls, and component states across all screens.
- Accessibility and narrow-screen constraints for the redesigned screens.
- Updating UI tests to cover the redesigned navigation and visible visual
  contract.

Out of scope:

- Implementing Favorites, Stats, Profile, or Review sections unless separate
  specs define those features.
- Remote game downloads, accounts, sync, or leaderboards.
- Changing SAN validation, timing rules, square-recognition scoring, or result
  calculations.
- Replacing game logic with a chess engine.

## Final Screen Map

The first completed redesign must define and implement this screen map unless a
later accepted spec changes it:

- Home: premium mode dashboard and Settings entry.
- Game Library: searchable/filterable game selection for Practice or Timed
  launch mode.
- Timed Duration: duration selection for timed notation games.
- Notation Game: shared practice/timed move-entry screen.
- Notation Results: shared practice/timed results screen.
- Square Recognition Setup: time and variant selection plus history entry.
- Square Recognition Game: timed square prompt and board-tapping screen.
- Square Recognition Results: run summary after timeout.
- Square Recognition History: locally persisted prior runs.
- Instructions: mode, SAN, timing, square recognition, and settings guidance.
- Settings/About: visual settings, board coordinates, evaluation visibility,
  theme selection, and app version.

Visible navigation entries must map to implemented screens in this list or to
screens introduced by another accepted spec.

## Design Tokens

The implementation must define a shared token layer rather than restyling each
screen independently. Tokens may live in Swift code, but they must be centralized
and reused by redesigned screens.

- Background: near-black/charcoal base with low-contrast board texture or
  premium vignette treatment.
- Primary text: high-contrast off-white.
- Secondary text: muted cool gray.
- Brand accent: warm gold for identity, highlights, and selected filters.
- Practice accent: green for practice mode, correct answers, and positive
  actions.
- Timed accent: blue for timed mode, speed, and timer-focused controls.
- Square-recognition accent: purple for square-recognition mode and prompts.
- Learning accent: amber/orange for instructions and learning surfaces.
- Error accent: red only for mistakes, low-time warnings, destructive states, or
  failed storage.
- Corner radius: 8 px for tiles, rows, buttons, panels, thumbnails, and search
  surfaces unless a native control requires a different shape.
- Spacing: 8 px grid increments for margins, gaps, and internal padding.
- Typography: large display title only for Home hero; compact headings for
  panels and rows; monospaced digits for timers, scores, and metrics.
- Primary buttons: filled, high-contrast, accent-specific.
- Secondary buttons: bordered or translucent with clear icon+label affordance.
- Icon buttons: circular or square 8 px radius controls with accessible labels.
- Rows: fixed or stable minimum heights so async images, badges, and labels do
  not shift layout after loading.

## Functional Requirements

- CN-SPEC-0010-FR001: Home must use a dark premium chess-themed presentation, visually close to the provided mock.
- CN-SPEC-0010-FR002: Home must include a top hero area with the app name, a concise training tagline, and chess-specific visual treatment.
- CN-SPEC-0010-FR003: Home must show large image-forward tiles for Notation Training, Timed Notation, Square Recognition, and Instructions.
- CN-SPEC-0010-FR004: Home tiles must use distinct artwork or rendered chess-specific visuals rather than generic SF Symbols as the primary visual.
- CN-SPEC-0010-FR005: Home tiles may use SF Symbols only as secondary affordances such as arrows, settings, or small status icons.
- CN-SPEC-0010-FR006: Settings must remain reachable from Home using a compact top-right control.
- CN-SPEC-0010-FR007: Home must not show search, game filters, or the full game library.
- CN-SPEC-0010-FR008: The Game Library must be a distinct screen with its own dark premium styling.
- CN-SPEC-0010-FR009: The Game Library must include a prominent search control near the top of the screen.
- CN-SPEC-0010-FR010: The Game Library must show filter chips for all difficulty and opening filters that are available in the current library data.
- CN-SPEC-0010-FR011: The Game Library must include a visually prominent random filtered game entry.
- CN-SPEC-0010-FR012: Each Game Library row must include a game-specific thumbnail preview, title, year when available, opening when available, player names, difficulty badge, and an affordance to open the game.
- CN-SPEC-0010-FR013: The Game Library must expose a clear launch-mode control or summary that identifies Practice or Timed mode.
- CN-SPEC-0010-FR014: In Practice mode, opening a game must start untimed notation training.
- CN-SPEC-0010-FR015: In Timed mode, opening a game must require duration selection before starting timed notation.
- CN-SPEC-0010-FR016: The visual redesign must keep the current Square Recognition setup and play flow reachable from Home.
- CN-SPEC-0010-FR017: The visual redesign must keep Instructions reachable from Home and consistent with the redesigned visual style.
- CN-SPEC-0010-FR018: Tiles, search, filters, game rows, and launch controls must remain readable and non-overlapping on narrow iPhone layouts.
- CN-SPEC-0010-FR019: Visual styling must preserve VoiceOver labels and stable accessibility identifiers for UI tests.
- CN-SPEC-0010-FR020: The design must avoid suggesting unavailable features such as Profile, Stats, Favorites, or Review unless those entries are disabled, hidden, or separately implemented.
- CN-SPEC-0010-FR021: Notation Training and Timed Notation game screens must adopt the same premium visual system for background, headers, board framing, timer, answer input, action buttons, stats, and feedback.
- CN-SPEC-0010-FR022: Timed results and untimed results must adopt the same premium visual system and present metrics in visually consistent rows or panels.
- CN-SPEC-0010-FR023: Square Recognition setup, play, results, and history must adopt the same premium visual system while preserving fast square tapping and clear prompt visibility.
- CN-SPEC-0010-FR024: Instructions and Settings must adopt the same premium visual system instead of retaining unrelated default system styling.
- CN-SPEC-0010-FR025: The redesign must define a shared component language for tiles, rows, badges, primary buttons, secondary buttons, icon buttons, search fields, filter chips, segmented controls, metric pills, and empty states.
- CN-SPEC-0010-FR026: The redesign may add, remove, split, or combine screens when the change improves the normal flow and does not remove any behavior required by accepted specs.
- CN-SPEC-0010-FR027: Any removed or hidden screen entry must not leave orphaned navigation, inaccessible functionality, misleading tabs, or dead UI controls.
- CN-SPEC-0010-FR028: Every redesigned screen must include a clear primary action or clear next step appropriate to that screen's purpose.
- CN-SPEC-0010-FR029: The premium visual system must define semantic accent use: gold for brand/highlight, green for practice/correct, blue for timed/speed, purple for square recognition, orange/gold for learning/instructions, and red only for errors, misses, or low-time warnings.
- CN-SPEC-0010-FR030: The redesign must avoid relying on generic icons as the main visual identity for any primary screen or mode; icons may support labels and actions but must not replace required artwork, board previews, or chess-specific visuals.
- CN-SPEC-0010-FR031: The implementation must provide a centralized shared design-token layer for colors, typography, spacing, corner radius, shadows, surfaces, buttons, rows, chips, and metric treatments.
- CN-SPEC-0010-FR032: Every redesigned screen must use the final screen map in this spec or document a replacement in a later accepted spec.
- CN-SPEC-0010-FR033: No visible tab, toolbar item, tile, chip, or row action may point to an unimplemented feature.
- CN-SPEC-0010-FR034: The redesigned screens must support Dynamic Type without making primary actions unreachable or causing incoherent overlap.
- CN-SPEC-0010-FR035: The redesigned screens must support VoiceOver labels for non-text artwork, thumbnails, icon-only controls, timers, scores, and result metrics.
- CN-SPEC-0010-FR036: Visual verification must include screenshots or equivalent UI snapshots for at least a small iPhone and a large iPhone viewport.
- CN-SPEC-0010-FR037: If iPad is a supported run destination, visual verification must include an iPad screenshot or an explicit documented reason why iPad is deferred.
- CN-SPEC-0010-FR038: The redesign must verify that text remains readable at large accessibility text sizes for Home tiles, library rows, game controls, result metrics, settings, and instructions.
- CN-SPEC-0010-FR039: The implementation must not use negative letter spacing or viewport-scaled font sizes to force the mock layout.

## Acceptance Criteria

- CN-SPEC-0010-AC001: Given the app launches, when Home appears, then the screen uses a dark premium chess-themed design with the app name and tagline visible.
- CN-SPEC-0010-AC002: Given Home appears, when mode options are inspected, then Notation Training, Timed Notation, Square Recognition, and Instructions are shown as image-forward tiles.
- CN-SPEC-0010-AC003: Given Home appears, when search or game filters are queried, then they are not present on Home.
- CN-SPEC-0010-AC004: Given Home appears, when Settings is selected, then the Settings screen opens from a compact control.
- CN-SPEC-0010-AC005: Given the player taps Notation Training, when navigation completes, then the Game Library appears in Practice mode.
- CN-SPEC-0010-AC006: Given the player taps Timed Notation, when navigation completes, then the Game Library appears in Timed mode.
- CN-SPEC-0010-AC007: Given the Game Library appears, when the top area is inspected, then search and filter chips are available before the game rows.
- CN-SPEC-0010-AC008: Given the Game Library appears, when game rows are inspected, then each visible row includes a thumbnail, game metadata, difficulty badge, and open affordance.
- CN-SPEC-0010-AC009: Given Practice mode is active, when a game is opened, then no active countdown timer is presented.
- CN-SPEC-0010-AC010: Given Timed mode is active, when a game is opened, then 1 minute, 3 minute, and 5 minute duration choices are presented before play.
- CN-SPEC-0010-AC011: Given Square Recognition is selected from Home, when navigation completes, then the existing square-recognition setup controls are visible.
- CN-SPEC-0010-AC012: Given Instructions is selected from Home, when navigation completes, then the instructions screen appears and matches the redesigned visual direction closely enough to not feel like a separate app surface.
- CN-SPEC-0010-AC013: Given Home is rendered on a narrow iPhone, when all tiles are visible through scrolling, then no tile title, subtitle, image, or action control overlaps.
- CN-SPEC-0010-AC014: Given Game Library is rendered on a narrow iPhone, when search, filters, random game, launch mode, and game rows are visible through scrolling, then no controls overlap or become unreachable.
- CN-SPEC-0010-AC015: Given VoiceOver or UI tests query the redesigned screens, when the main controls are focused, then stable labels and accessibility identifiers are available.
- CN-SPEC-0010-AC016: Given a notation training game is opened, when the game screen appears, then its background, header, board area, input, actions, stats, and feedback match the premium visual system.
- CN-SPEC-0010-AC017: Given a timed notation game is opened, when the game screen appears, then the timer, warning state, board area, input, actions, stats, and feedback match the premium visual system.
- CN-SPEC-0010-AC018: Given notation results are shown, when metrics and restart actions are inspected, then results use the same premium row, panel, and button styling as the rest of the app.
- CN-SPEC-0010-AC019: Given Square Recognition setup is opened, when time and variant controls are inspected, then the screen uses the premium visual system and clearly presents the start action.
- CN-SPEC-0010-AC020: Given Square Recognition play is active, when prompt, board, timer, stats, feedback, and white-side cue are inspected, then they use the premium visual system without reducing square tap reliability.
- CN-SPEC-0010-AC021: Given Square Recognition results or history are shown, when run metrics and historical rows are inspected, then they use the same premium metric and row styling as other result surfaces.
- CN-SPEC-0010-AC022: Given Instructions is opened, when sections and SAN examples are inspected, then the screen uses the premium visual system and remains readable.
- CN-SPEC-0010-AC023: Given Settings is opened, when toggles, theme choices, and version footer are inspected, then the screen uses the premium visual system and remains readable.
- CN-SPEC-0010-AC024: Given any screen is removed, hidden, split, or combined during redesign, when the app is navigated end-to-end, then all behavior required by accepted specs remains reachable.
- CN-SPEC-0010-AC025: Given a primary redesigned screen appears, when the player scans it, then a clear primary action or next step is visible without requiring instruction text.
- CN-SPEC-0010-AC026: Given the implementation is inspected, when shared visual styling is located, then colors, typography, spacing, radius, surfaces, buttons, chips, rows, and metric treatments come from a centralized token layer.
- CN-SPEC-0010-AC027: Given the app is navigated after redesign, when every visible navigation entry is followed, then no entry leads to an unimplemented or placeholder-only screen.
- CN-SPEC-0010-AC028: Given Home, Game Library, Notation Game, Results, Square Recognition, Instructions, and Settings render with large Dynamic Type, when primary content is inspected, then text remains understandable and primary actions remain reachable.
- CN-SPEC-0010-AC029: Given visual verification is run, when small and large iPhone screenshots are captured, then Home and Game Library match the premium mock direction and have no overlapping primary UI.
- CN-SPEC-0010-AC030: Given iPad is supported, when visual verification is run, then an iPad screenshot is captured; otherwise the verification notes iPad as deferred.

## Coverage

- Pending coverage: CN-SPEC-0010-AC001
- Pending coverage: CN-SPEC-0010-AC002
- Pending coverage: CN-SPEC-0010-AC003
- Pending coverage: CN-SPEC-0010-AC004
- Pending coverage: CN-SPEC-0010-AC005
- Pending coverage: CN-SPEC-0010-AC006
- Pending coverage: CN-SPEC-0010-AC007
- Pending coverage: CN-SPEC-0010-AC008
- Pending coverage: CN-SPEC-0010-AC009
- Pending coverage: CN-SPEC-0010-AC010
- Pending coverage: CN-SPEC-0010-AC011
- Pending coverage: CN-SPEC-0010-AC012
- Pending coverage: CN-SPEC-0010-AC013
- Pending coverage: CN-SPEC-0010-AC014
- Pending coverage: CN-SPEC-0010-AC015
- Pending coverage: CN-SPEC-0010-AC016
- Pending coverage: CN-SPEC-0010-AC017
- Pending coverage: CN-SPEC-0010-AC018
- Pending coverage: CN-SPEC-0010-AC019
- Pending coverage: CN-SPEC-0010-AC020
- Pending coverage: CN-SPEC-0010-AC021
- Pending coverage: CN-SPEC-0010-AC022
- Pending coverage: CN-SPEC-0010-AC023
- Pending coverage: CN-SPEC-0010-AC024
- Pending coverage: CN-SPEC-0010-AC025
- Pending coverage: CN-SPEC-0010-AC026
- Pending coverage: CN-SPEC-0010-AC027
- Pending coverage: CN-SPEC-0010-AC028
- Pending coverage: CN-SPEC-0010-AC029
- Pending coverage: CN-SPEC-0010-AC030

## Open Questions

- Should a bottom navigation bar be implemented later, or should the first pass avoid it because Stats, Profile, Favorites, and Review are not implemented?
- Should the app force dark appearance for these screens, or adapt the premium design to system light and dark modes?
- Should Settings remain a sheet, become a pushed screen, or be grouped with an About screen if the premium redesign needs a more complete support surface?
- Should Square Recognition history remain nested inside setup, or become a first-class screen if history becomes visually important?
- Should iPad be included in the first redesign verification pass, or explicitly deferred until the iPhone visual system is stable?

## Revision Notes

- 2026-06-27: Initial proposed spec for mock-driven premium visual redesign.
- 2026-06-27: Expanded scope to require the same premium visual system across all app screens and allow screen additions/removals when they improve flow.
- 2026-06-27: Added final screen map, design tokens, no-fake-navigation rule, Dynamic Type requirements, and visual screenshot verification requirements.
