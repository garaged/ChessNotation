# Changelog

All notable changes to this project will be documented in this file.

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

