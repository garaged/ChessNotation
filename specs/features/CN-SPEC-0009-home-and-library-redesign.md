# CN-SPEC-0009: Home and Game Library Redesign

Status: Accepted
Owner: Project
Last updated: 2026-06-27

## Intent

ChessNotation should open to a polished mode dashboard instead of mixing mode
selection, filters, search, and game rows on one screen. The home screen should
make the main training choices immediately clear, while game search and filters
should live on a dedicated Game Library screen reached from notation modes.

The target visual direction follows the provided mock: a rich chess-themed home
screen with large training tiles, and a separate library screen with search,
filter chips, game rows, a random filtered game entry, and an explicit launch
mode control.

## Scope

In scope:

- Replacing the current list-based Home start area with a tile-based dashboard.
- Keeping Home focused on top-level destinations: notation training, timed
  notation, square recognition, instructions, and settings.
- Moving game library search, filters, random filtered game, and game rows to a
  dedicated Game Library screen.
- Supporting both practice and timed notation launch paths from the Game Library.
- Preserving the existing bundled game source, filtering semantics, and SAN
  validation behavior.
- Updating instructions and UI tests to reflect the redesigned navigation.

Out of scope:

- User profiles, favorites, stats tabs, or bottom-tab navigation unless a later
  spec defines them.
- Downloading remote games.
- Changing notation validation, timed session scoring, or square-recognition
  scoring rules.
- Requiring photographic or generated image assets for the first implementation.
  Native SwiftUI visual treatments are acceptable if they meet the layout and
  clarity requirements.

## Functional Requirements

- CN-SPEC-0009-FR001: The app must show a Home screen whose primary content is a dashboard of large tappable tiles for Notation Training, Timed Notation, Square Recognition, and Instructions.
- CN-SPEC-0009-FR002: The Home screen must not show the full game library, game search field, difficulty filter, or opening filter.
- CN-SPEC-0009-FR003: The Notation Training tile must navigate to a Game Library screen configured for untimed practice launch.
- CN-SPEC-0009-FR004: The Timed Notation tile must navigate to the same Game Library screen configured for timed launch.
- CN-SPEC-0009-FR005: The Square Recognition tile must navigate to the existing square-recognition setup flow.
- CN-SPEC-0009-FR006: The Instructions tile must navigate to the instructions flow.
- CN-SPEC-0009-FR007: Settings must remain reachable from Home without competing with the primary training tiles.
- CN-SPEC-0009-FR008: The Game Library screen must expose search, difficulty filtering, opening filtering when available, and a random filtered game action.
- CN-SPEC-0009-FR009: Library search and filters must apply to both untimed and timed notation launch modes.
- CN-SPEC-0009-FR010: In untimed launch mode, selecting a game or random filtered game must start an untimed notation session.
- CN-SPEC-0009-FR011: In timed launch mode, selecting a game or random filtered game must require choosing a supported duration before starting the timed session.
- CN-SPEC-0009-FR012: Supported timed notation durations must continue to include 1 minute, 3 minutes, and 5 minutes.
- CN-SPEC-0009-FR013: The Game Library screen must visually identify its current launch mode so players understand whether opening a game will practice untimed or start timed setup.
- CN-SPEC-0009-FR014: The redesign must preserve accessibility identifiers or provide replacements for UI tests covering Home tiles, library filters, game rows, timed duration setup, square recognition launch, and instructions launch.
- CN-SPEC-0009-FR015: The redesigned screens must remain usable on narrow iPhone layouts without overlapping tile text, controls, filters, search, game rows, or launch controls.

## Acceptance Criteria

- CN-SPEC-0009-AC001: Given the app launches, when Home appears, then the primary visible choices are tile-style entries for Notation Training, Timed Notation, Square Recognition, and Instructions.
- CN-SPEC-0009-AC002: Given Home appears, when the player looks for game search or library filters, then those controls are not shown on Home.
- CN-SPEC-0009-AC003: Given the player taps Notation Training, when the next screen appears, then the Game Library is shown in practice mode with search, filters, random filtered game, and game rows.
- CN-SPEC-0009-AC004: Given the player taps Timed Notation, when the next screen appears, then the Game Library is shown in timed mode with search, filters, random filtered game, and game rows.
- CN-SPEC-0009-AC005: Given the Game Library is in practice mode, when the player selects a game, then an untimed notation session starts with no active countdown timer.
- CN-SPEC-0009-AC006: Given the Game Library is in timed mode, when the player selects a game, then duration choices for 1 minute, 3 minutes, and 5 minutes are presented before the game starts.
- CN-SPEC-0009-AC007: Given the Game Library is in timed mode and the player selects 3 minutes, when the game starts, then the notation session starts with a 3-minute countdown.
- CN-SPEC-0009-AC008: Given the player applies difficulty, opening, or search filters in the Game Library, when random filtered game is used, then the selected game comes from the filtered result set.
- CN-SPEC-0009-AC009: Given the player applies difficulty, opening, or search filters in the Game Library, when game rows are shown, then only matching games are listed and opening filter options remain sorted.
- CN-SPEC-0009-AC010: Given the player taps Square Recognition on Home, when navigation completes, then the square-recognition setup screen appears with its time and variant controls.
- CN-SPEC-0009-AC011: Given the player taps Instructions on Home, when navigation completes, then the updated instructions screen appears.
- CN-SPEC-0009-AC012: Given Home is displayed on a narrow iPhone layout, when all mode tiles render, then tile labels and subtitles do not overlap or truncate in a way that prevents understanding the choices.
- CN-SPEC-0009-AC013: Given Game Library is displayed on a narrow iPhone layout, when search, filters, random game, launch mode, and game rows render, then the controls remain reachable and do not overlap.

## Coverage

- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0009-AC001, CN-SPEC-0009-AC002, CN-SPEC-0009-AC003, CN-SPEC-0009-AC004, CN-SPEC-0009-AC005, CN-SPEC-0009-AC006, CN-SPEC-0009-AC007, CN-SPEC-0009-AC008, CN-SPEC-0009-AC010, CN-SPEC-0009-AC011, CN-SPEC-0009-AC012, CN-SPEC-0009-AC013
- `ChessNotationTests/NotationServicesTests.swift`: CN-SPEC-0009-AC009

## Open Questions

- Should Home use two-column tiles on all iPhone sizes, or switch to single-column tiles on the narrowest devices if text fit becomes tight?
- Should the first implementation include decorative chess artwork in tiles, or use SF Symbols and board-texture styling until a dedicated asset spec exists?
- Should the Game Library launch mode be fixed by the Home tile that opened it, or should players be able to switch between Practice and Timed inside the library?

## Revision Notes

- 2026-06-27: Initial proposed spec for mock-driven Home and Game Library redesign.
