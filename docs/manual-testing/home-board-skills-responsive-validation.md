# Home and Board Skills Responsive Validation

Date: 2026-08-23
Branch: `agent/ui-validation-and-release-readiness`
Commit under validation: `900a36b`
Release target: `3.0.1` build `1`

## Summary

This record tracks CN-SPEC-0026 and CN-SPEC-0027 rendered validation for Home and Board Skills.

Automated source, asset, build, and Xcode-runner checks passed on 2026-08-23. Manually captured screenshots were inspected from `docs/manual-testing/screenshots/home-board-skills/2026-08-23/`.

Default Dynamic Type screenshots pass the Home and Board Skills rendered acceptance checks. The refreshed Home accessibility Dynamic Type screenshot passes. The refreshed Board Skills accessibility screenshot confirms the Quick Start clipping fix, but the drill rows are partly below the bottom of the viewport and need a scrolled accessibility capture before the row-specific criteria can be accepted.

## Baseline Commands

| Check | Command | Result | Notes |
| --- | --- | --- | --- |
| Home tile assets | `make validate-home-assets` | PASS | All five Home tile assets are 1422 x 1106 PNG, 9:7, RGB, no alpha, unmanaged RGB. |
| Asset script tests | `.venv/bin/python -m unittest scripts.tests.test_validate_home_tile_assets scripts.tests.test_normalize_home_tile_assets` | PASS | 19 tests passed. |
| Spec validation | `python3 scripts/spec_check.py` | PASS | 13 feature specs validated. |
| Xcode build | Xcode MCP `BuildProject` | PASS | Project built successfully. |
| Home layout tests | Xcode MCP `RunSomeTests`, `ChessNotationTests/HomeTileLayoutRegressionTests` | PASS | 7 tests passed. |
| Home UI tests | Xcode MCP `RunSomeTests`, `ChessNotationUITests/HomeUITests` | PASS | 8 tests passed. |
| Shell Home layout tests | `xcodebuild test -project ChessNotation.xcodeproj -scheme ChessNotation -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChessNotationTests/HomeTileLayoutRegressionTests` | UNRUN | Shell `xcodebuild` exited 70 because no iPhone 16 simulator destination was visible. |
| Shell Home UI tests | `xcodebuild test -project ChessNotation.xcodeproj -scheme ChessNotation -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChessNotationUITests/HomeUITests` | UNRUN | Shell `xcodebuild` exited 70 because no iPhone 16 simulator destination was visible. |

## Baseline Verification

| Requirement | Status | Evidence |
| --- | --- | --- |
| App target marketing version is `3.0.1` | PASS | `ChessNotation.xcodeproj/project.pbxproj` app target Debug and Release build settings. |
| App target build is `1` | PASS | `CURRENT_PROJECT_VERSION = 1` for app target Debug and Release. |
| Bundle identifier unchanged | PASS | `PRODUCT_BUNDLE_IDENTIFIER = org.garaged.chessnotation.ChessNotation`. |
| Home artwork viewport is 9:7 | PASS | `HomeLayout.artworkAspectRatio = 9.0 / 7.0`; `HomeTileLayoutRegressionTests.familyArtworkUsesSharedNineBySevenViewportWithoutPerCardScale`. |
| All five Home source assets are 1422 x 1106 RGB | PASS | `make validate-home-assets`. |
| No Position Recall-specific SwiftUI scale override exists | PASS | Source audit and `HomeTileLayoutRegressionTests.familyArtworkUsesSharedNineBySevenViewportWithoutPerCardScale`. |
| Instructions remains outside gameplay grid | PASS | `HomeUITests.testInstructionsMatchesFamilyCardGeometryAndIsCentered`; source audit. |
| Board Skills uses Quick Start plus two drill rows | PASS | `HomeUITests.testBoardSkillsUsesQuickStartAndTwoAlignedCompactRows`; source audit. |

## Required Screenshot Matrix

| ID | Simulator/Device | Orientation | Dynamic Type | Command Used | Result | Screenshot Path | Defects Found | Severity | Fix Commit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| HBV-001 | iPhone SE-class | Portrait | Default | Manual simulator screenshot | PASS | `docs/manual-testing/screenshots/home-board-skills/2026-08-23/home-iphone-se-portrait-default.png`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-iphone-se-portrait-default.png` | None found. | N/A | N/A |
| HBV-002 | iPhone 16-class | Portrait | Default | Manual simulator screenshot; MCP tests run | PASS | `docs/manual-testing/screenshots/home-board-skills/2026-08-23/home-iphone-16-portrait-default.png`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-iphone-16-portrait-default.png` | None found. | N/A | N/A |
| HBV-003 | Pro Max-class | Portrait | Default | Manual simulator screenshot | PASS | `docs/manual-testing/screenshots/home-board-skills/2026-08-23/home-iphone-pro-max-portrait-default.png`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-iphone-pro-max-portrait-default.png` | None found. | N/A | N/A |
| HBV-004 | iPad | Portrait | Default | Manual simulator screenshot | PASS | `docs/manual-testing/screenshots/home-board-skills/2026-08-23/home-ipad-portrait-default.png`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-ipad-portrait-default.png` | None found. | N/A | N/A |
| HBV-005 | iPad | Landscape | Default | Manual simulator screenshot | PASS | `docs/manual-testing/screenshots/home-board-skills/2026-08-23/home-ipad-landscape-default.png`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-ipad-landscape-default.png` | None found. | N/A | N/A |
| HBV-006 | iPhone 16-class | Portrait | Accessibility size | Manual simulator screenshot | PARTIAL | `docs/manual-testing/screenshots/home-board-skills/2026-08-23/home-iphone-16-portrait-accessibility.png`; `docs/manual-testing/screenshots/home-board-skills/2026-08-23/board-skills-iphone-16-portrait-accessibility.png` | Home hero text passes. Board Skills Quick Start text passes. Board Skills drill rows require a scrolled screenshot because the first row is partly below the bottom of the viewport. | Medium | `5bdc29c` |

## Home Acceptance Checklist

| Check | Automated Status | Visual Status | Evidence |
| --- | --- | --- | --- |
| Exactly four gameplay family cards | PASS | PASS | Home UI and source tests; inspected screenshots. |
| Complete 2x2 grid at normal Dynamic Type | PASS | PASS | Home UI frame assertions; inspected default Dynamic Type screenshots. |
| One column at accessibility Dynamic Type | PASS | PASS | Accessibility screenshot shows one-column layout. |
| Identical family card width and height | PASS | PASS | Home UI frame assertions; inspected screenshots. |
| Identical artwork viewport | PASS | PASS | Source regression guardrails; inspected screenshots. |
| Consistent perceived artwork scale | PARTIAL | PASS | Source normalization validated; inspected screenshots show no disproportionate Position Recall zoom. |
| No card intersection or touching | PASS | PASS | Home UI frame assertions; inspected screenshots. |
| Visible horizontal and vertical gutters | PASS | PASS | Home UI frame assertions; inspected screenshots. |
| No clipped or ellipsized important copy | PASS | PASS | Refreshed Home accessibility screenshot shows complete hero title/subtitle and visible family-card copy. |
| Hero below navigation/status safe area | PASS | PASS | Inspected screenshots. |
| Settings does not float over hero | PASS | PASS | Inspected screenshots. |
| Bounded centered width on iPad | PARTIAL | PASS | Source max-width guardrail; inspected iPad screenshots. |
| Position Recall not disproportionately zoomed | PARTIAL | PASS | Source scale override removed; inspected screenshots. |
| Instructions outside grid, centered, same shape | PASS | PASS | Home UI frame assertions; inspected screenshots including help-view captures. |

## Board Skills Acceptance Checklist

| Check | Automated Status | Visual Status | Evidence |
| --- | --- | --- | --- |
| Family summary is concise | PASS | PASS | Source audit; inspected screenshots. |
| Quick Start is clearly primary | PASS | PASS | Source hierarchy, Home UI tests, inspected screenshots. |
| Quick Start launches Square Recognition | PASS | PASS | Home UI tests. |
| Choose a drill hierarchy is clear | PASS | PASS | Source audit; inspected screenshots. |
| Square Recognition and Piece Movement rows share width/height | PASS | PASS | Home UI frame assertions; inspected default screenshots. |
| Rows align leading edges and preserve positive spacing | PASS | PASS | Home UI frame assertions; inspected screenshots. |
| Rows have matching artwork dimensions | PASS | PASS | Source shared `FamilyGameRow`; inspected screenshots. |
| Rows have no clipping or intersection | PASS | PARTIAL | Refreshed accessibility screenshot confirms Quick Start text is no longer clipped. Drill rows need a scrolled screenshot because they are partly below the viewport. |
| No duplicate Home-style grid | PASS | PASS | Source regression guardrails; inspected screenshots. |
| Bounded width on iPad | PARTIAL | PASS | Source max-width guardrail; inspected iPad screenshots. |
| Dynamic Type remains usable | PARTIAL | PARTIAL | Refreshed accessibility screenshot confirms the header and Quick Start remain usable; drill rows need a scrolled screenshot. |

## Decision

CN-SPEC-0026 and CN-SPEC-0027 remain `Proposed`.

Reason: automated evidence is strong, default-size rendered screenshots passed, and the refreshed Home accessibility screenshot passed. Board Skills still needs a scrolled accessibility screenshot that shows the full Square Recognition and Piece Movement rows before the row-specific acceptance criteria can be closed.
