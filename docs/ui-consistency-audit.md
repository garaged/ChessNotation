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

- App Store versioning has been corrected to `3.0.1`, but the correction still needs an archive/upload validation.
- CN-SPEC-0027 is accepted based on automated checks and the completed rendered screenshot matrix.
- CN-SPEC-0026 remains `Proposed` because broader family-screen navigation and results-return behavior is still incomplete.
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
| Shell Release generic build | UNRUN | Default DerivedData path failed with sandbox write permissions; retry with `-derivedDataPath /tmp/ChessNotationDerivedData` progressed but failed in `CompileAssetCatalogVariant` because `actool` reported no available simulator runtimes. |

## Screen Review

| Area | Screens Reviewed | Source/Test Evidence | Status |
| --- | --- | --- | --- |
| Home / families | Home, Board Skills, Instructions card, Settings toolbar | `RestoredHomeView.swift`, `HomeTileLayoutRegressionTests`, `HomeUITests`, inspected screenshots | Home and Board Skills responsive layout evidence passes. |
| Notation | Game library, filters/search, full-game training, results, notation history | `HomeView.swift`, `GameTrainingView.swift`, `ResultsView.swift`, existing UI/integration tests | Usable; family-screen ownership remains incomplete against CN-SPEC-0026. |
| Timed | Timed setup, timed gameplay, timed results/history | `TimedGameConfigurationView` in `HomeView.swift`, `GameTrainingView.swift`, `ResultsView.swift`, timed tests | Usable; family-screen ownership remains incomplete against CN-SPEC-0026. |
| Board Skills | Board Skills family, Square Recognition setup/game/results/history, Piece Movement game/results | `RestoredHomeView.swift`, `SquareRecognitionViews.swift`, `PieceMovementFeature.swift`, Home UI tests, inspected screenshots | Home/Board Skills layout contract passes; broader family ownership remains under CN-SPEC-0026. |
| Recall | Position Recall launcher/game/results | `RestoredHomeView.swift`, `PositionRecallReconstructionView.swift`, recall tests | Gameplay works; family-screen hierarchy is incomplete. |
| Utilities | Settings, appearance/board settings, Instructions, SAN guide, insights model surface | `AppearanceSettingsView.swift`, `InstructionsView.swift`, `TrainingInsightsFeature.swift` | No blocker found by source audit; rendered review pending. |

## Findings

| ID | Screen | Device | Severity | Category | Issue | Evidence | Owning Spec | Recommended Fix | Status | Commit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| UIAUD-001 | Home / Board Skills | Device matrix | Medium | Release evidence | Required rendered screenshot matrix is complete for CN-SPEC-0027, but CN-SPEC-0026 still has broader family-screen navigation and results-return gaps. | `docs/manual-testing/home-board-skills-responsive-validation.md`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-iphone-16-portrait-2-drills-accessibility.png`. | CN-SPEC-0026 | Continue the family-screen/navigation implementation or narrow CN-SPEC-0026 before acceptance. | Open | Pending |
| UIAUD-002 | Validation tooling | Local shell | Medium | Release validation | Shell `xcodebuild` cannot access the requested `iPhone 16` simulator in this environment, blocking the exact commands listed in the release prompt. | `xcodebuild` exited 70 and listed only placeholder simulator destinations from the shell; Xcode MCP tests passed. | CN-SPEC-0027 | Run the same commands on a local machine with visible simulator runtimes, or add CI/device workflow support for rendered validation. | Open | N/A |
| UIAUD-003 | Home / Position Recall | All | High | Navigation hierarchy | Position Recall is a primary Home family tile but currently launches directly into beginner reconstruction gameplay rather than a family screen with summary, Quick Start, choices, and secondary actions. | `RestoredHomeView.swift` routes `home.positionRecallLink` to `PositionRecallLauncherView()`. | CN-SPEC-0026 | Add a Position Recall family screen or narrow CN-SPEC-0026 before acceptance. Preserve the existing beginner reconstruction Quick Start. | Open | N/A |
| UIAUD-004 | Home / Notation and Timed | All | Medium | Navigation hierarchy | Notation Training and Timed Training primary family tiles route directly to `GameLibraryView` variants. This preserves current launch paths but does not present a distinct family screen with explicit Quick Start versus game choice. | `RestoredHomeView.swift` routes both tiles directly to `GameLibraryView`. | CN-SPEC-0026 | Decide whether `GameLibraryView` is the accepted family screen for these families and document/update tests, or add thin family wrappers with Quick Start and library entry points. | Open | N/A |
| UIAUD-005 | Results / mini-games | All | Medium | Navigation ownership | Piece Movement and Position Recall results support Play Again but do not expose an explicit Done/Back to Games action inside the results surface. Users can rely on navigation Back, but CN-SPEC-0026 asks for owning-family return behavior. | `PieceMovementFeature.swift` and `PositionRecallReconstructionView.swift` completion summaries show `Play Again` but no explicit Done action. | CN-SPEC-0026 | Add explicit Done/Back to Games where family ownership is implemented, or document platform Back as the accepted behavior before spec acceptance. | Open | N/A |
| UIAUD-006 | Settings | iPhone/iPad | Low | Visual consistency | Settings theme cards use larger 18/20/22 corner radii while Home family cards use 16 and `PremiumDesign.Radius.large` is 8 elsewhere. This is visual inconsistency, not a release blocker. | `AppearanceSettingsView.swift`; `RestoredHomeView.swift`; `PremiumDesign.swift`. | None | Leave for polish unless repeated screenshot review shows hierarchy or clipping problems. | Open | N/A |
| UIAUD-007 | Game training answer icons | Touch devices | Low | Accessibility/touch target | Inline answer backspace and submit icon frames are 28 x 28 inside a larger padded answer field. Effective touch target may be acceptable through padding, but rendered hit area should be verified. | `GameTrainingView.swift` icon frames at 28 x 28. | CN-SPEC-0022 | Confirm with rendered accessibility inspection; adjust only if hit target is actually below 44 x 44. | Open | N/A |
| UIAUD-008 | Release build validation | Local shell | Medium | Release validation | Archive-oriented shell build could not complete in this environment. A writable DerivedData path avoided the first failure, but asset catalog compilation still failed because Xcode tooling could not access simulator runtime services. | `xcodebuild -project ChessNotation.xcodeproj -scheme ChessNotation -configuration Release -destination 'generic/platform=iOS' -derivedDataPath /tmp/ChessNotationDerivedData build` exited 65 in `CompileAssetCatalogVariant`. | Release checklist | Re-run the Release generic build or archive in Xcode/local shell with normal CoreSimulator and DerivedData access before submission. | Open | N/A |
| UIAUD-009 | Home / Board Skills | iPhone 16 accessibility Dynamic Type | High | Accessibility typography | Original accessibility Dynamic Type screenshots clipped important Home hero text and Board Skills Quick Start/drill row text. | Refreshed `home-iphone-16-portrait-accessibility.png`, `board-skills-iphone-16-portrait-accessibility.png`, and `board-skills-iphone-16-portrait-2-drills-accessibility.png` pass. | CN-SPEC-0027 | No further fix needed for this finding. | Closed | `5bdc29c` |

## Category Notes

### Layout

Home and Board Skills have strong source and frame-test coverage. Default-size rendered screenshots passed across the requested device classes. Refreshed accessibility screenshots passed for Home, Board Skills Quick Start, and Board Skills drill rows. Other gameplay surfaces are scroll-based and mostly use semantic fonts and system controls, but rendered iPad and accessibility Dynamic Type review is still required before release.

### Typography

Primary surfaces generally use semantic fonts. The remaining risk is visual hierarchy consistency between premium Home/Board Skills cards and older mini-game/result screens that use more default SwiftUI styling.

### Components

Board Skills now follows the required Quick Start plus compact drill rows. Settings and mini-game result summaries use local component styling; these are acceptable for now unless screenshot review reveals repeated inconsistency.

### Imagery

Home tile artwork passes metadata validation and source rendering uses the shared 9:7 viewport. Subjective perceived-scale acceptance still requires screenshot review.

### Navigation

Board Skills is the clearest family implementation. Position Recall, Notation Training, and Timed Training need a product decision or implementation pass before CN-SPEC-0026 should be accepted.

### Accessibility

Existing tests cover board-square semantics, Dynamic Type source guardrails, Reduce Motion feedback, and several UI flows. The Home/Board Skills accessibility screenshots found real clipping in fixed-height premium surfaces; the current fix removes those fixed-height caps at accessibility sizes. Refreshed screenshots confirm Home, Board Skills Quick Start, and Board Skills drill rows. The audit did not find hidden-answer leakage in Position Recall accessibility labels by source inspection; recall tests also cover study/answer state semantics.

## Next Recommended Fixes

1. Decide whether to implement thin family screens for Position Recall, Notation Training, and Timed Training, or revise CN-SPEC-0026 to match the current hierarchy.
2. Add explicit Done/Back to Games behavior for mini-game result screens once family ownership is finalized.
3. Run Release generic build and archive/upload validation after version `3.0.1` is confirmed in an environment with normal CoreSimulator and DerivedData access.
