# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - 2026-07-15

### Added
- External keyboard command routing for notation answer entry/edit/submit/reveal and primary mini-game submit/next/finish flows.
- Regression coverage for external keyboard notation, Piece Movement, and Position Recall command behavior.
- CN-SPEC-0022 release validation traceability covering performance, security, accessibility, bundled-data, and UI smoke coverage.

### Changed
- Bundled game loading now validates each payload, omits later duplicate stable game IDs across overlapping catalogs, and keeps valid sibling records playable.
- Documentation now states local-only privacy behavior, persistence schema and corruption recovery behavior, bounded cache/history policies, accessibility behavior, keyboard support, known limits, and exact validation results.

### Fixed
- Prevented duplicate game IDs across configured catalogs from breaking library loading or SwiftUI list identity.

## [2.0.2] - 2026-06-28

### Added
- Current-position evaluation display for evaluated notation games, using stored bundled engine data from the reached board position.
- Local notation and timed-notation history with accuracy, first-try rate, completion, move timing, pace, finish reason, and weak move-tag metrics.
- Today, last-week, last-month, and last-year history range filters across notation, timed notation, and square-recognition history.
- Trend charts with y-axis context, sparse x-axis labels, visible data points, and tap-to-read temporary value overlays.
- Schema-versioned square-recognition history decoding that preserves existing saved results.
- Expanded AI-agent operating documentation for spec-driven development workflows.

### Changed
- Evaluation context now follows the current visible board position instead of the pending prompt.
- Square-recognition history now includes summary metrics and score/latency trends.
- Timed notation history now emphasizes pace, completion, finish reason, and selected duration.
- Result screens now report history-save failures without blocking the result summary or further play.

### Fixed
- Prevented fabricated neutral evaluations when evaluated data is unavailable for the current position.
- Prevented duplicate notation history records when results are revisited or restarted.

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
