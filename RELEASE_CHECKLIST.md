# Release Checklist

## Current Release

- Version: `3.0.1`
- Build: `1`
- Date: 2026-08-23
- Scope: recovered training families, Board Skills, Position Recall reconstruction, Piece Movement, responsive Home/Board Skills layout, external keyboard hardening, local-only history resilience, and App Store version correction above the closed `3.0.0` train.

## GitHub

- Confirm `README.md` reflects current features and setup
- Review `CHANGELOG.md` for the `3.0.1` entry
- Confirm Xcode app target uses marketing version `3.0.1` and build `1`
- Confirm `LICENSE` is present and referenced in docs
- Verify screenshots or demo media are ready for the repository page
- Tag the release as `v3.0.1` after merging the release commit

## App Store

- Replace placeholder app metadata in Xcode
- Verify app name, subtitle, keywords, and description
- Use `RELEASE_DESCRIPTION.md` as the baseline App Store description for this release
- Confirm App Store copy mentions recovered training families, Board Skills, Position Recall reconstruction, Piece Movement, current-position evaluation, training history, timed notation, square recognition, and visual board themes
- Prepare App Store screenshots for supported device sizes
- Confirm the privacy policy is published and linked in App Store Connect
- Verify app privacy answers in App Store Connect match `PRIVACY.md`
- Test on a physical device before submission
- Validate archive and upload through Xcode Organizer

## Product quality

- Run the full test suite
- Smoke test the main training flow manually
- Smoke test timed notation timeout and completion paths
- Smoke test square recognition setup, play, results, and history
- Smoke test notation and timed notation history save, range filtering, trend x-axis labels, and tap-to-read chart values
- Smoke test current-position evaluation on evaluated and non-evaluated games
- Verify rendered chess-piece PNGs have transparent backgrounds on every board theme
- Verify board style previews stay square in Settings
- Verify the bundled game library loads without errors
- Confirm accessibility labels still cover the main UI flow

## CN-SPEC-0022 Validation Notes

Validation run on 2026-07-15 for `agent/recover-missing-games-specs`:

- `make spec-check`: passed, 12 feature spec(s) validated.
- Xcode targeted CN-SPEC-0022 hardening batch: passed, 54 tests.
- Xcode complete `ChessNotationTests` unit/integration target: passed, 264 tests.
- Xcode critical UI suites split by suite: passed, 12 tests across `HomeUITests`, `GameLibraryUITests`, `GameplayUITests`, `SquareRecognitionUITests`, and `TimedGameUITests`.
- `xcodebuild test -project ChessNotation.xcodeproj -scheme ChessNotation -destination 'platform=iOS Simulator,name=iPhone 16'`: not completed in the sandboxed shell. `xcodebuild` exited 70 because no matching iPhone 16 simulator destination was available; the shell saw only placeholder simulator destinations.

Validated behavior includes local-only privacy surface, bounded FEN/history policies, bundled-game validation and duplicate catalog omission, Position Recall schema migration/corruption preservation/reset behavior, Dynamic Type reachability, VoiceOver board-square semantics, Reduce Motion feedback equivalence, and external keyboard answer/navigation command routing.

Known release limitations:

- Physical-device validation and App Store archive/upload remain manual release steps.
- The app uses bundled move data and stored evaluations; it does not perform runtime chess-engine analysis.
- External keyboard support covers supported training answer/navigation commands and does not turn every screen into a full hardware-keyboard editing surface.
