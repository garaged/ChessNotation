# vNext Correction Release Manual Testing Plan

Status: Ready for manual testing
Last updated: 2026-07-08

## Goal

Manually validate the corrected training-game release after CN-SPEC-0017 through CN-SPEC-0021 were completed and accepted, including the CN-SPEC-0021 product-facing insights integration merged in PR #24.

This stage focuses on real app behavior that automated tests cannot fully prove: navigation, pacing, accessibility, layout, persistence feel, edge-case recovery, and whether the new games and recommendation surfaces are understandable without reading implementation details.

## Preflight

- [x] Pull latest `main` after PR #24.
- [x] Run `make spec-check`.
- [ ] Run the focused simulator suite below.
- [ ] Build and launch on the target iOS Simulator.
- [ ] Build and launch on at least one compact iPhone simulator.
- [ ] Optional: run once on a physical device before release tagging.

```sh
make spec-check

xcodebuild test \
  -project ChessNotation.xcodeproj \
  -scheme ChessNotation \
  -destination 'platform=iOS Simulator,id=2EAAECDA-9648-453E-9C6B-1AAA4CD18234' \
  -only-testing:ChessNotationTests/TimedNotationCompletionTests \
  -only-testing:ChessNotationTests/SquareRecognitionVarietyTests \
  -only-testing:ChessNotationTests/SquareRecognitionSessionTests \
  -only-testing:ChessNotationTests/SquareRecognitionIntegrationTests \
  -only-testing:ChessNotationTests/ExpandedSquareRecognitionViewModelTests \
  -only-testing:ChessNotationTests/PieceMovementGameTests \
  -only-testing:ChessNotationTests/PieceMovementSessionTests \
  -only-testing:ChessNotationTests/PieceMovementFeatureTests \
  -only-testing:ChessNotationTests/NotationConceptGameTests \
  -only-testing:ChessNotationTests/NotationConceptSessionTests \
  -only-testing:ChessNotationTests/PositionRecallGameTests \
  -only-testing:ChessNotationTests/PositionRecallReconstructionSessionTests \
  -only-testing:ChessNotationTests/PositionRecallReconstructionViewModelTests \
  -only-testing:ChessNotationTests/NotationTrainingVarietyTests \
  -only-testing:ChessNotationTests/TrainingInsightsTests \
  -only-testing:ChessNotationTests/TrainingInsightsFeatureTests
```

## Manual smoke pass

### App launch and navigation

- [x] App launches without migration or startup errors.
- [x] Home screen loads quickly.
- [x] Existing notation training entry points still open.
- [ ] New or expanded training screens do not create duplicate navigation stacks.
- [ ] Back navigation works from every new game screen.
- [ ] App returns from background without losing current game state unexpectedly.

### Timed notation variants — CN-SPEC-0017

- [ ] Start each timed variant: sprint, survival, combo, accuracy race.
- [ ] Complete a short run with correct answers.
- [ ] Complete a short run with incorrect answers.
- [ ] Verify score, accuracy, elapsed time, and prompt counts look coherent.
- [ ] Verify personal-best messaging does not compare incompatible variants.
- [ ] Verify legacy completion/result screens still display reasonable values.

### Square recognition variety — CN-SPEC-0018

- [ ] Find-square drill accepts board taps.
- [ ] Name-square drill accepts coordinate text input.
- [ ] Square-color drill accepts light/dark answers.
- [ ] Relative-square drill maps target offsets correctly.
- [ ] Route drill requires ordered taps and handles wrong order clearly.
- [ ] White, black, and alternating orientation display correctly.
- [ ] Restricted zones do not generate outside-zone prompts.
- [ ] Feedback lock prevents double scoring during transitions.
- [ ] VoiceOver labels describe coordinates according to visible orientation.

### Piece movement game — CN-SPEC-0019

- [ ] Empty-board movement works for king, queen, rook, bishop, knight, and pawn.
- [ ] Friendly blockers are visible and not selectable as legal destinations.
- [ ] Enemy pieces are visible and selectable only when capturable.
- [ ] Sliding pieces stop at first blocker or capture.
- [ ] Pawns move in side-relative direction.
- [ ] Black orientation tap mapping still validates the same coordinate.
- [ ] Missing and extra selections are explained in text.
- [ ] Long destination sets remain usable on compact devices.
- [ ] VoiceOver identifies piece, source, blockers, selected squares, feedback, and progress.

### Notation concept games — CN-SPEC-0020

- [ ] SAN Builder presents sensible component choices.
- [ ] SAN Builder accepts correct simple moves, captures, castling, promotion, disambiguation, check, and mate.
- [ ] SAN Builder reports the first incorrect component without spoiling the full answer.
- [ ] Position Recall study phase clearly shows what to memorize.
- [ ] Position Recall hides the intended data after the study phase.
- [ ] Hidden phase does not expose concealed pieces visually or through VoiceOver labels.
- [ ] Locate-piece, occupant, occupied-subset, and reconstruction interactions are understandable.
- [ ] Reconstruction piece/side controls are usable before submit.
- [ ] Missing, extra, wrong-piece, and wrong-side feedback is clear.
- [ ] History/result summaries preserve game-specific metrics.

### Local insights and library personalization — CN-SPEC-0021

- [ ] Favorite games can be added and removed from the product-facing library surface where exposed.
- [ ] Favorite state survives app restart where exposed.
- [ ] Recent games are ordered most-recent-first.
- [ ] Recent-game filtering avoids repeats when alternatives exist.
- [ ] Recent-game filtering falls back to all candidates when every eligible game is recent.
- [ ] Recommendation copy gives transparent evidence and uses fallback when history is sparse.
- [ ] Recommendation route or selected game IDs match the recommended category when eligible content exists.
- [ ] Recommendation accessibility summary includes recommendation, evidence, favorite IDs, recent IDs, and recommended game IDs where exposed.
- [ ] No network/account prompt appears for local personalization.

## Accessibility and layout pass

- [ ] VoiceOver smoke pass on all new screens.
- [ ] Dynamic Type at large accessibility size does not block primary actions.
- [ ] Dark mode contrast is acceptable.
- [ ] Portrait layout is usable on compact iPhone.
- [ ] Landscape or rotation behavior does not break board geometry.
- [ ] Reduced Motion does not affect game correctness.

## Persistence and recovery pass

- [ ] Complete at least one session in each new game family.
- [ ] Toggle at least one favorite and record at least one recent game where exposed.
- [ ] Kill and relaunch app.
- [ ] Confirm persisted results/preferences are still readable.
- [ ] Start a game, background the app, return, and continue or recover cleanly.
- [ ] Invalid or sparse content states show fallback/empty messaging rather than hanging.

## Release-readiness criteria

Release can be finalized when:

- [ ] `make spec-check` passes.
- [ ] Focused simulator suite passes.
- [ ] Manual smoke pass has no release-blocking issues.
- [ ] Accessibility/layout pass has no release-blocking issues.
- [ ] Persistence/recovery pass has no release-blocking issues.
- [ ] Any defects found are filed with reproduction steps, expected behavior, actual behavior, device/simulator, and screenshots/video when useful.

## Defect triage levels

- **Blocker:** crash, data loss, unusable primary flow, broken navigation, hidden answer leaked in recall, impossible-to-finish game.
- **High:** incorrect scoring, wrong coordinate mapping, inaccessible primary action, persistence corruption, severe layout clipping, local recommendation points to mismatched content.
- **Medium:** confusing copy, non-critical layout issue, awkward but usable flow, minor result-display issue, recommendation evidence could be clearer.
- **Low:** polish, wording, minor visual alignment, nice-to-have telemetry-free insight improvements.

## Exit note

When this checklist is complete, create a final release-candidate PR or tag prep commit with:

- final changelog summary,
- known issues, if any,
- manual test date,
- simulator/device coverage,
- decision: release, fix-forward, or hold.
