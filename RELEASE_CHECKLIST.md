# Release Checklist

## GitHub

- Confirm `README.md` reflects current features and setup
- Review `CHANGELOG.md`
- Confirm `LICENSE` is present and referenced in docs
- Verify screenshots or demo media are ready for the repository page
- Tag a release after merging the release commit

## App Store

- Replace placeholder app metadata in Xcode
- Verify app name, subtitle, keywords, and description
- Prepare App Store screenshots for supported device sizes
- Confirm the privacy policy is published and linked in App Store Connect
- Verify app privacy answers in App Store Connect match `PRIVACY.md`
- Test on a physical device before submission
- Validate archive and upload through Xcode Organizer

## Product quality

- Run the full test suite
- Smoke test the main training flow manually
- Verify the bundled game library loads without errors
- Confirm accessibility labels still cover the main UI flow
