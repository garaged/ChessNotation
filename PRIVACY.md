# Privacy Policy

ChessNotation does not require an account and does not collect personal data from users inside the app.

## Data handling

- No sign-in
- No analytics SDK
- No advertising SDK
- No in-app purchases
- No user-generated content upload
- No tracking, telemetry, cloud sync, or remote networking added by the current roadmap
- No advertising identifier use
- No unnecessary permission prompts or entitlements

## Local data

The app uses bundled chess game data shipped with the app package. Evaluated game files contain stored engine evaluations; ChessNotation does not run remote or runtime engine analysis.

Training history is stored locally on device and is not synced to a server. Current local history surfaces include notation, timed notation, square recognition, piece movement, and position recall results.

Position Recall reconstruction history is stored in a schema-versioned local JSON envelope. Legacy unwrapped result arrays are migrated on the next successful save. Unsupported future schemas are rejected rather than decoded with guessed defaults.

If Position Recall reconstruction history is corrupt or rejected, the app preserves the payload once as a sibling `.corrupt` evidence file where practical. The reset path removes the primary history file while leaving preserved corrupt evidence available for diagnosis or manual recovery.

Local hardening limits include:

- FEN board cache capacity: 256 normalized positions
- Position Recall reconstruction history file limit: 2 MiB
- Position Recall reconstruction history record limit: 5,000 records
- Bounded long-session challenge generation state
- Bundled game validation for malformed coordinates, invalid FEN placement, empty required fields, duplicate IDs, and inconsistent records

## Future changes

If analytics, cloud sync, crash reporting, or account features are added later, this policy must be updated before release.
