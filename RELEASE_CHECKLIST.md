# Release Checklist

## Current Release

- Version: `2.0.2`
- Build: `1`
- Date: 2026-06-28
- Scope: current-position evaluation for evaluated games, all-mode local history, interactive history trend charts, timed notation, square recognition, game thumbnails, and rendered chess-piece assets.

## GitHub

- Confirm `README.md` reflects current features and setup
- Review `CHANGELOG.md` for the `2.0.2` entry
- Confirm Xcode app target uses marketing version `2.0.2` and build `1`
- Confirm `LICENSE` is present and referenced in docs
- Verify screenshots or demo media are ready for the repository page
- Tag the release as `v2.0.2` after merging the release commit

## App Store

- Replace placeholder app metadata in Xcode
- Verify app name, subtitle, keywords, and description
- Use `RELEASE_DESCRIPTION.md` as the baseline App Store description for this release
- Confirm App Store copy mentions current-position evaluation, training history, timed notation, square recognition, and visual board themes
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
