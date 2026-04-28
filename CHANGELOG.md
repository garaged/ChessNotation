# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-04-27

### Added
- Added a custom chess notation keyboard for SAN move entry, with dedicated piece, file, rank, capture, castling, check, checkmate, promotion, clear, delete, and submit controls.
- Added context-aware keyboard availability so promotion, castling, check, and checkmate inputs guide the learner toward valid notation patterns.
- Added an inline answer display with backspace and submit actions, replacing reliance on the system keyboard during training.
- Added unit coverage for chess notation key availability rules.
- Added updated phone and iPad screenshots under `docs/screenshots`.

### Changed
- Updated the training screen layout to place session stats first, followed by progress, the board, answer entry, and the custom notation keyboard.
- Combined move progress and attempt state into a single compact training label, such as `Move 2 of 23 (attempt 1/3)`.
- Updated UI tests to interact with the custom notation keyboard instead of typing into a system text field.
- Aligned app and test target deployment settings to iOS `17.6`.

### Fixed
- Removed focus-management logic that repeatedly forced the system text field to become active during move progression.
- Reduced accidental input friction by keeping all chess notation keys visible in the training flow.
- Fixed test target deployment configuration that was set to an invalid future iOS target.

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
