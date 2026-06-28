# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-06-28

### Added
- Premium home experience with rendered hero artwork, mode tiles, and reusable premium design styling.
- Timed notation mode with selectable durations, countdown display, timeout finish state, and timed results metrics.
- Square recognition trainer with time-limit selection, bonus and strict variants, immediate board feedback, results, and local history.
- Game thumbnail previews that render board positions from bundled game data in the library.
- Transparent rendered chess-piece artwork for both sides, replacing Unicode/vector piece rendering in board previews and gameplay.
- Premium visual assets for the home hero, mode tiles, dark board texture, and chess pieces.
- Spec coverage for the premium visual redesign, visual asset prompts, thumbnail previews, and rendered artwork quality.

### Changed
- Updated the game board renderer to use bundled image assets through `ChessPieceGraphic`.
- Enlarged chess-piece rendering while preserving square padding.
- Refined board style settings previews to use a compact square king/queen reference board.
- Expanded the home screen from a library-first view into a mode launcher for notation, timed notation, square recognition, and instructions.
- Updated instructions to cover current training modes and settings.
- Modernized result, settings, home, and square-recognition surfaces with premium panel and background treatments.
- Bumped the app release version to `2.0.0` with build `10`.

### Fixed
- Corrected settings board-style previews that previously appeared as rectangular strips instead of square boards.
- Ensured piece assets use alpha-capable image sets so board square colors remain visible behind pieces.

## [1.0.0] - 2025-02-14

### Added
- Curated bundled game library with starter, master, and featured training games.
- Library browsing with random game launch, difficulty filtering, opening filtering, and search.
- Training flow for SAN move entry with hints, reveal support, per-move attempt tracking, and results summary.
- In-game chessboard with custom themed piece sets and selectable board styles: Current, Marble, Wood, and Metal.
- Detailed instructions screens, including a dedicated SAN notation guide.
- Optional engine-evaluation support sourced from evaluated game files when available.
- Evaluation bar with animated transitions, numeric evaluation display, and engine depth indicator.
- Per-difficulty evaluation settings with beginner off by default and higher levels enabled by default.
- Compact in-session statistics card for solved moves, accuracy, and first-try performance.
- Unit, integration, and UI test coverage for notation services, decoding, filtering, and gameplay flows.

### Changed
- Unified board-piece rendering with custom vector graphics for consistent style across both sides.
- Improved game-screen focus behavior so SAN entry stays active across move progression.
- Reduced home-screen and training-screen startup overhead by tightening library loading behavior.
- Updated bundled opening names to use readable opening titles instead of raw ECO placeholders.
- Added support for mixed bundled JSON formats, including single-game files, multi-game files, and evaluated variants.
- Configured app icon appearances for light, dark, and tinted Home Screen variants.

### Fixed
- Corrected navigation model conformance required by SwiftUI destination routing.
- Prevented hints and evaluation labels from revealing the current answer before resolution.
- Fixed year formatting in library cards to avoid localized thousands separators.
- Fixed board sizing and evaluation-bar layout issues that could cause overflow on smaller screens.
- Preserved compatibility with older game JSON files that do not include engine evaluation data.
