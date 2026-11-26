# Board legibility redesign plan

This plan implements [CN-SPEC-0028](../specs/features/CN-SPEC-0028-board-legibility-and-piece-scale.md). It is intentionally iPhone-first: a board that is beautiful on an iPad but slow to scan on a phone has failed the product goal.

## Current-main audit

`main` at `8e05c0e` renders four board themes from gradient endpoints. The current `ChessPiece.scale` values span 0.74 for a pawn to 0.94 for a king, and the mini-game boards separately hard-code 0.82. Those frame values do not measure the transparent margin inside the PNGs, so their visible footprints can be materially smaller than the code suggests. The current palette has no formal contrast or adverse-square test; a dark piece can merge into a dark square and a light piece into a light square.

## Design intent

The redesign should read like a refined tournament board under controlled studio light, not a decorative texture. The board establishes a reliable spatial rhythm; pieces establish the strongest visual hierarchy; game-state accents sit above both. Saturation is restrained and used only for attention, never to make a side recognizable.

### Color-theory strategy

1. **Separate roles before choosing hues.** The board uses a light, cool neutral and a dark, desaturated blue/graphite. Their luminance difference carries the checker pattern. Hue variation provides character, but never substitutes for lightness contrast.
2. **Give each side a stable value family.** White pieces are near-white porcelain with a dark navy/keyline; black pieces are deep blue-black graphite with a pale ice keyline. The opposite contour appears only where it preserves the silhouette against its adverse square. It is a legibility device, not an accent color.
3. **Keep the chromatic axis quiet.** Each theme may warm or cool its board surface, but its light square remains high value and its dark square remains low value. This lets Marble, Wood, and Metal retain personality without turning the chess position into low-contrast decoration.
4. **Reserve strong color for game state.** Teal/green means correct or selected, blue means source/context, amber means learning/attention, and red means error/low time. State also changes shape or outline, so meaning never depends on hue alone.
5. **Prefer broad forms over fine detail.** Mobile antialiasing makes thin ornament vanish. Each Staunton-inspired silhouette uses a bold head, body, and base, with one discriminating feature per kind: cross/crown, crown points, crenellations, mitre cut, horse profile, or round head.

The 3:1 minimum for meaningful graphical objects follows WCAG 2.2 non-text contrast guidance. The product target is deliberately stronger at the piece boundary because a chess player must scan 64 small graphics quickly, and antialiasing weakens thin contours in practice. genui{"citation":{"ref":"turn0search0"}}

### Target visual system

| Layer | Default target | Purpose |
| --- | --- | --- |
| Light square | cool light neutral, roughly `#DEE8F0` | low-noise field for dark pieces and labels |
| Dark square | desaturated deep teal/blue, roughly `#2E617A` | firm checker cadence without a neon-green cast |
| White piece core | porcelain neutral, roughly `#F7FAFC` | immediate white-side recognition |
| White piece contour | ink navy, roughly `#102331` | recovery against light squares and structural definition |
| Black piece core | graphite navy, roughly `#101A24` | immediate black-side recognition |
| Black piece contour | ice neutral, roughly `#DDEBF1` | recovery against dark squares and a crisp outer silhouette |
| State accents | existing restrained green/blue/amber/red family | state hierarchy, never side identity |

The exact final values are implementation tokens and must pass the measurement gates; the table expresses color roles, not a license to use unverified approximate values.

### Piece-size strategy

The unit of design is the **visible alpha bounds**, not the image canvas or a SwiftUI frame. The proposed optical footprint is 80% of a square for pawns and 86–92% for all other kinds, capped below 96% after rendering inset. This raises pawns materially above the current nominal 74% scale and prevents the small-piece problem without allowing bases to touch the square edge.

A single `ChessPiecePresentationMetrics` policy will resolve a frame, presentation inset, contour width, and optical-size adjustment from square size and piece kind. Gameplay, mini-games, previews, and thumbnails will call it. It should clamp mobile contours to a real rendered thickness rather than rely on a fractional hairline.

## Delivery sequence

### Phase 0 — Baseline evidence and contract

- Preserve the exact `main` baseline in this branch and record the current scale/dependency audit.
- Add the proposed CN-SPEC-0028 contract and this plan.
- Capture baseline screenshots for the smallest supported iPhone, largest iPhone, and iPad. Include a mixed position that exercises white/black pieces on both square colors, coordinate labels, arrow, selection, and evaluation bar.
- Do not change UI behavior in this phase.

Exit gate: `make spec-check` passes and the visual/technical decisions are ready to implement.

### Phase 1 — Testable rendering contract

- Introduce pure feature-level color and sizing metrics; do not put visual layout policy in `Domain`.
- Add unit tests for relative luminance, contrast ratio, all 16 piece/square boundary combinations, and exact scale/clearance ranges.
- Add asset-audit tests that inspect PNG alpha bounds and reject rectangular opaque backgrounds, insufficient occupancy, missing transparency, or unstable assets.
- Add source/structural checks only where they protect architecture; do not substitute string matching for layout or visual evidence.

Exit gate: metrics and asset validations fail against an intentionally invalid fixture and pass against the approved set.

### Phase 2 — Piece set and palette implementation

- Produce one transparent, matched, Staunton-inspired white/black piece family and replace the twelve production PNGs while retaining their stable asset names.
- Rebalance all existing theme palettes through the central visual contract, retaining their persisted identifiers and their intended material character.
- Update `ChessBoardView`, `ThemedMiniGameBoard`, settings previews, and thumbnails to consume shared metrics.
- Ensure coordinates, arrows, overlays, and evaluation labels use the same documented contrast-recovery rules.

Exit gate: focused unit/asset tests pass; existing gameplay semantics remain untouched.

### Phase 3 — iPhone layout and interaction validation

- Give the chessboard a compact-phone width budget and evaluate the evaluation-bar trade-off. Board readability wins over evaluation-bar width.
- Add UI tests that navigate into notation training, Piece Movement, and Position Recall, assert stable identifiers/labels, and capture the required board states.
- Run rendered checks at 5.4-inch and 6.7-inch iPhone widths first, then an 11-inch iPad. Inspect normal and accessibility Dynamic Type cases.
- Manually validate real-device-style touch targets: board still fits, action buttons are reachable, and no overlay obscures the intended square.

Exit gate: both iPhone screenshots are free of clipping, overlap, low-contrast state markers, or undersized pieces; iPad retains the same legible hierarchy.

### Phase 4 — Regression, documentation, and review

- Run spec validation, focused tests, the full test suite, and the release build.
- Update the user-facing appearance description only if the resulting visual behavior needs a clearer explanation.
- Update CN-SPEC-0028 coverage from pending to exact files and mark it Accepted only after every criterion has evidence.
- Commit focused slices on this branch and open one coherent pull request after all gates pass.

## Test matrix

| Risk | Protection | Why it is the right test |
| --- | --- | --- |
| Palette looks attractive but a piece disappears | deterministic luminance/contrast matrix | catches every side/square/theme pairing without subjective judgment |
| PNG canvas is large but artwork is visually tiny | alpha-bounds occupancy audit | measures the visible pixels that players actually see |
| One board path diverges from another | shared-metrics unit tests plus integration references | protects notation, mini-games, previews, and thumbnails from scale drift |
| Compact phone sacrifices the board to the evaluation bar | device-specific UI render and frame inspection | sees the final composition, not just constants |
| Visual overhaul breaks training | existing full-game and mini-game UI smoke tests | protects the user journey and identifiers |
| Large text pushes actions away | targeted Dynamic Type UI verification | protects the primary task while keeping the board scannable |
| Theme migration resets a preference | settings persistence regression test | preserves users' selected board style |

## Definition of done

The work is complete only when CN-SPEC-0028 is Accepted, all four themes' piece-side contrast relationships for both square colors are proven, asset alpha bounds and optical footprints are measured, the shared metrics are used by every board surface, full user flows pass, and the two required iPhone renders have been visually reviewed. A palette screenshot alone is not acceptance evidence.
