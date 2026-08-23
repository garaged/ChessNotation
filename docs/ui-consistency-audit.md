# UI Consistency and Release Readiness Audit

Date: 2026-08-23
Branch: `agent/ui-validation-and-release-readiness`
Release target: `3.0.1` build `1`

## Audit Scope

This audit reviews release readiness from source inspection, existing regression coverage, Xcode MCP build/test results, and the Home/Board Skills validation baseline in `docs/manual-testing/home-board-skills-responsive-validation.md`.

Home and Board Skills rendered screenshots were inspected from `docs/manual-testing/screenshots/home-board-skills/2026-08-23/`. Default Dynamic Type cases passed. The refreshed Home and Board Skills accessibility screenshots passed, including a scrolled Board Skills capture showing both drill rows.

## Release Decision

Status: Not ready to publish.

Reasons:

- App Store versioning has been corrected to `3.0.1`, but the correction still needs an Xcode Organizer archive/upload validation.
- CN-SPEC-0027 is accepted based on automated checks and the completed rendered screenshot matrix.
- CN-SPEC-0026 is accepted based on typed family metadata, family screens, result-return controls, and automated coverage.
- App-wide visual review is source/test-based in this pass; device screenshots and physical-device checks remain required.

## Automated Evidence

| Check | Result | Notes |
| --- | --- | --- |
| `make validate-home-assets` | PASS | Five Home tile assets are 1422 x 1106 PNG, 9:7, RGB, no alpha. |
| `.venv/bin/python -m unittest scripts.tests.test_validate_home_tile_assets scripts.tests.test_normalize_home_tile_assets` | PASS | 19 tests passed. |
| `python3 scripts/spec_check.py` | PASS | 13 feature specs validated. |
| Xcode MCP `BuildProject` | PASS | Project built successfully. |
| Xcode MCP `ChessNotationTests/HomeTileLayoutRegressionTests` | PASS | 7 tests passed. |
| Xcode MCP `ChessNotationUITests/HomeUITests` | PASS | 8 tests passed. |
| Shell `xcodebuild` Home tests on `iPhone 16` | UNRUN | Command-line CoreSimulator access unavailable; exited 70 with no matching destination. |
| Shell Release generic build | BLOCKED | Retried with `-derivedDataPath /tmp/ChessNotationReleaseDerivedData`; Swift compilation began, but asset catalog compilation failed because sandboxed CoreSimulator services reported no available simulator runtimes. |

## Screen Review

| Area | Screens Reviewed | Source/Test Evidence | Status |
| --- | --- | --- | --- |
| Home / families | Home, Board Skills, Instructions card, Settings toolbar | `RestoredHomeView.swift`, `HomeTileLayoutRegressionTests`, `HomeUITests`, inspected screenshots | Home and Board Skills responsive layout evidence passes. |
| Notation | Notation family, game library, filters/search, full-game training, results, notation history | `GameFamilyCatalog.swift`, `RestoredHomeView.swift`, `HomeView.swift`, `GameTrainingView.swift`, `ResultsView.swift`, UI/integration tests | Family ownership accepted under CN-SPEC-0026. |
| Timed | Timed family, timed setup, timed gameplay, timed results/history | `GameFamilyCatalog.swift`, `RestoredHomeView.swift`, `TimedGameConfigurationView` in `HomeView.swift`, `GameTrainingView.swift`, `ResultsView.swift`, timed tests | Family ownership accepted under CN-SPEC-0026. |
| Board Skills | Board Skills family, Square Recognition setup/game/results/history, Piece Movement game/results | `GameFamilyCatalog.swift`, `RestoredHomeView.swift`, `SquareRecognitionViews.swift`, `PieceMovementFeature.swift`, Home UI tests, inspected screenshots | Family ownership and layout contract pass. |
| Recall | Position Recall family, reconstruction game/results/history | `GameFamilyCatalog.swift`, `RestoredHomeView.swift`, `PositionRecallReconstructionView.swift`, recall tests | Family ownership accepted under CN-SPEC-0026. |
| Utilities | Settings, appearance/board settings, Instructions, SAN guide, insights model surface | `AppearanceSettingsView.swift`, `InstructionsView.swift`, `TrainingInsightsFeature.swift` | No blocker found by source audit; rendered review pending. |

## Findings

| ID | Screen | Device | Severity | Category | Issue | Evidence | Owning Spec | Recommended Fix | Status | Commit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| UIAUD-001 | Home / Board Skills | Device matrix | Medium | Release evidence | Required rendered screenshot matrix is complete for CN-SPEC-0027, and CN-SPEC-0026 family-screen/navigation gaps are implemented. | `docs/manual-testing/home-board-skills-responsive-validation.md`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-iphone-16-portrait-2-drills-accessibility.png`; `GameFamilyCatalogTests`; `HomeUITests`; `GameplayUITests`; `TimedGameUITests`. | CN-SPEC-0026, CN-SPEC-0027 | No further fix needed. | Closed | Pending |
| UIAUD-002 | Validation tooling | Local shell | Medium | Release validation | Shell `xcodebuild` cannot access the requested `iPhone 16` simulator in this environment, blocking the exact commands listed in the release prompt. | `xcodebuild` exited 70 and listed only placeholder simulator destinations from the shell; Xcode MCP tests passed. | CN-SPEC-0027 | Run the same commands on a local machine with visible simulator runtimes, or add CI/device workflow support for rendered validation. | Open | N/A |
| UIAUD-003 | Home / Position Recall | All | High | Navigation hierarchy | Position Recall now opens a family screen with summary, Quick Start, recall choices, unavailable-entry explanations, and history. | `RestoredHomeView.swift`; `GameFamilyCatalog.swift`; `HomeUITests/testPositionRecallTileOpensFamilyAndQuickStartOpensGame()`. | CN-SPEC-0026 | No further fix needed. | Closed | Pending |
| UIAUD-004 | Home / Notation and Timed | All | Medium | Navigation hierarchy | Notation Training and Timed Training now open family screens with explicit Quick Start, game choices, unavailable-entry explanations, and history links. | `RestoredHomeView.swift`; `GameFamilyCatalog.swift`; `HomeUITests/testNotationAndTimedFamiliesExposeQuickStartAndHistory()`. | CN-SPEC-0026 | No further fix needed. | Closed | Pending |
| UIAUD-005 | Results / mini-games | All | Medium | Navigation ownership | Notation, Piece Movement, and Position Recall results expose Play Again and Back to Games; timed results expose Change Setup with the completed duration represented. | `ResultsView.swift`; `GameTrainingView.swift`; `PieceMovementFeature.swift`; `PositionRecallReconstructionView.swift`; `GameplayUITests`; `TimedGameUITests`. | CN-SPEC-0026 | No further fix needed. | Closed | Pending |
| UIAUD-006 | Settings | iPhone/iPad | Low | Visual consistency | Settings theme cards use larger 18/20/22 corner radii while Home family cards use 16 and `PremiumDesign.Radius.large` is 8 elsewhere. This is visual inconsistency, not a release blocker. | `AppearanceSettingsView.swift`; `RestoredHomeView.swift`; `PremiumDesign.swift`; rechecked 2026-08-23. | None | Leave for polish; no release-blocking action needed. | Closed as non-blocking | N/A |
| UIAUD-007 | Game training answer icons | Touch devices | Low | Accessibility/touch target | Inline answer backspace and submit icons remain visually 28 x 28, but each button now has an explicit 44 x 44 hit frame. | `GameTrainingView.swift` wraps both answer buttons in 44 x 44 frames with rectangular content shapes. | CN-SPEC-0022 | No further fix needed. | Closed | Pending |
| UIAUD-008 | Release build validation | Local shell | Medium | Release validation | Archive-oriented shell build still cannot complete in this environment. A writable DerivedData path avoids sandbox write failure and Swift compilation starts, but asset catalog compilation fails because sandboxed CoreSimulator services report no simulator runtimes. | `xcodebuild -project ChessNotation.xcodeproj -scheme ChessNotation -configuration Release -destination 'generic/platform=iOS' -derivedDataPath /tmp/ChessNotationReleaseDerivedData build` exited 65 in `CompileAssetCatalogVariant`; Xcode MCP `BuildProject` passed. | Release checklist | Re-run the Release generic build or archive in Xcode Organizer/local shell with normal CoreSimulator service access before submission. | Blocked by environment | N/A |
| UIAUD-009 | Home / Board Skills | iPhone 16 accessibility Dynamic Type | High | Accessibility typography | Original accessibility Dynamic Type screenshots clipped important Home hero text and Board Skills Quick Start/drill row text. | Refreshed `home-iphone-16-portrait-accessibility.png`, `board-skills-iphone-16-portrait-accessibility.png`, and `board-skills-iphone-16-portrait-2-drills-accessibility.png` pass. | CN-SPEC-0027 | No further fix needed for this finding. | Closed | `5bdc29c` |

## Category Notes

### Layout

Home and Board Skills have strong source and frame-test coverage. Default-size rendered screenshots passed across the requested device classes. Refreshed accessibility screenshots passed for Home, Board Skills Quick Start, and Board Skills drill rows. Other gameplay surfaces are scroll-based and mostly use semantic fonts and system controls, but rendered iPad and accessibility Dynamic Type review is still required before release.

### Typography

Primary surfaces generally use semantic fonts. The remaining risk is visual hierarchy consistency between premium Home/Board Skills cards and older mini-game/result screens that use more default SwiftUI styling.

### Components

Board Skills now follows the required Quick Start plus compact drill rows. Settings and mini-game result summaries use local component styling; the Settings radius difference was rechecked and classified as non-blocking polish.

### Imagery

Home tile artwork passes metadata validation and source rendering uses the shared 9:7 viewport. Subjective perceived-scale acceptance still requires screenshot review.

### Navigation

All four Home families now have explicit family screens. Non-surfaced current-release variants remain discoverable as unavailable rows with recovery guidance instead of launching empty or incomplete gameplay screens.

### Accessibility

Existing tests cover board-square semantics, Dynamic Type source guardrails, Reduce Motion feedback, and several UI flows. The Home/Board Skills accessibility screenshots found real clipping in fixed-height premium surfaces; the current fix removes those fixed-height caps at accessibility sizes. Refreshed screenshots confirm Home, Board Skills Quick Start, and Board Skills drill rows. The game-training answer buttons now have explicit 44 x 44 touch targets. The audit did not find hidden-answer leakage in Position Recall accessibility labels by source inspection; recall tests also cover study/answer state semantics.

## Next Recommended Fixes

1. Run Release generic build and archive/upload validation after version `3.0.1` is confirmed in an environment with normal CoreSimulator and DerivedData access.
2. Complete physical-device smoke validation before App Store submission.
