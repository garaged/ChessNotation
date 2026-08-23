# Home and Board Skills Responsive Validation

Date: 2026-08-23
Branch: `agent/ui-validation-and-release-readiness`
Commit under validation: `900a36b`
Release target: `3.0.1` build `1`

## Summary

This record tracks CN-SPEC-0026 and CN-SPEC-0027 rendered validation for Home and Board Skills.

Automated source, asset, build, and Xcode-runner checks passed on 2026-08-23. The required full device screenshot matrix remains unrun in this environment because command-line `xcodebuild` cannot access CoreSimulator devices from the sandbox and no rendered screenshot artifact was available from the Xcode MCP runner.

Do not mark CN-SPEC-0026 or CN-SPEC-0027 Accepted from this record alone. The specs require inspected rendered screenshots across the device matrix.

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
| HBV-001 | iPhone SE-class | Portrait | Default | Not run | UNRUN | N/A | Screenshot capture unavailable in current environment. | N/A | N/A |
| HBV-002 | iPhone 16-class | Portrait | Default | Shell `xcodebuild` requested; MCP tests run | UNRUN | N/A | Shell simulator destination unavailable; MCP tests passed but no screenshot artifact was available to inspect. | N/A | N/A |
| HBV-003 | Pro Max-class | Portrait | Default | Not run | UNRUN | N/A | Screenshot capture unavailable in current environment. | N/A | N/A |
| HBV-004 | iPad | Portrait | Default | Not run | UNRUN | N/A | Screenshot capture unavailable in current environment. | N/A | N/A |
| HBV-005 | iPad | Landscape | Default | Not run | UNRUN | N/A | Screenshot capture unavailable in current environment. | N/A | N/A |
| HBV-006 | iPhone 16-class | Portrait | Accessibility size | Not run | UNRUN | N/A | Screenshot capture unavailable in current environment. | N/A | N/A |

## Home Acceptance Checklist

| Check | Automated Status | Visual Status | Evidence |
| --- | --- | --- | --- |
| Exactly four gameplay family cards | PASS | UNRUN | Home UI and source tests. |
| Complete 2x2 grid at normal Dynamic Type | PASS | UNRUN | Home UI frame assertions. |
| One column at accessibility Dynamic Type | PASS | UNRUN | Source regression guardrails. |
| Identical family card width and height | PASS | UNRUN | Home UI frame assertions. |
| Identical artwork viewport | PASS | UNRUN | Source regression guardrails. |
| Consistent perceived artwork scale | PARTIAL | UNRUN | Source normalization validated; subjective screenshot review still required. |
| No card intersection or touching | PASS | UNRUN | Home UI frame assertions. |
| Visible horizontal and vertical gutters | PASS | UNRUN | Home UI frame assertions; screenshot review still required. |
| No clipped or ellipsized important copy | PASS | UNRUN | Source line-limit guardrails; screenshot review still required. |
| Hero below navigation/status safe area | PASS | UNRUN | Source guardrails; screenshot review still required. |
| Settings does not float over hero | PASS | UNRUN | Toolbar source guardrails; screenshot review still required. |
| Bounded centered width on iPad | PARTIAL | UNRUN | Source max-width guardrail; iPad screenshot review required. |
| Position Recall not disproportionately zoomed | PARTIAL | UNRUN | Source scale override removed; subjective screenshot review required. |
| Instructions outside grid, centered, same shape | PASS | UNRUN | Home UI frame assertions. |

## Board Skills Acceptance Checklist

| Check | Automated Status | Visual Status | Evidence |
| --- | --- | --- | --- |
| Family summary is concise | PASS | UNRUN | Source audit. |
| Quick Start is clearly primary | PASS | UNRUN | Source hierarchy and Home UI tests; screenshot review still required. |
| Quick Start launches Square Recognition | PASS | UNRUN | Home UI tests. |
| Choose a drill hierarchy is clear | PASS | UNRUN | Source audit; screenshot review still required. |
| Square Recognition and Piece Movement rows share width/height | PASS | UNRUN | Home UI frame assertions. |
| Rows align leading edges and preserve positive spacing | PASS | UNRUN | Home UI frame assertions. |
| Rows have matching artwork dimensions | PASS | UNRUN | Source shared `FamilyGameRow`. |
| Rows have no clipping or intersection | PASS | UNRUN | Home UI frame assertions; screenshot review still required for clipping. |
| No duplicate Home-style grid | PASS | UNRUN | Source regression guardrails. |
| Bounded width on iPad | PARTIAL | UNRUN | Source max-width guardrail; iPad screenshot review required. |
| Dynamic Type remains usable | PARTIAL | UNRUN | Source uses semantic fonts; screenshot review required. |

## Decision

CN-SPEC-0026 and CN-SPEC-0027 remain `Proposed`.

Reason: automated evidence is strong, but the required rendered screenshot matrix was not completed or inspected in this environment.
