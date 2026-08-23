# Home Tile Asset Normalization

CN-SPEC-0027 requires Home tile source artwork to use one canonical source geometry before visual completion can be claimed.

## Target Specification

- Canvas: 1422 x 1106 px
- Aspect ratio: 9:7
- Format: PNG
- Color: RGB
- Color profile: embedded sRGB is accepted but not required; unmanaged RGB is valid; explicitly incompatible embedded ICC profiles are rejected
- Alpha: none expected
- No baked-in text, borders, rounded corners, arrows, shadows, or UI chrome
- Background extends to all canvas edges

Safe composition region for future normalization work:

- Left/right safe margin: 214 px
- Top/bottom safe margin: 133 px
- Safe content region: 994 x 840 px
- Optical center reference: x = 711, y = 531

Recommended perceived subject scale when producing or re-normalizing artwork:

- Notation Training: 58-62% of canvas width
- Timed Training: 55-60% of canvas width
- Board Skills: 48-55% of canvas width
- Position Recall: 45-52% of canvas width
- Instructions: 55-62% of canvas width

Position Recall should be composed deliberately smaller than the other gameplay tiles when necessary because its multi-piece composition can carry greater visual mass. This normalization belongs in the source artwork rather than in a one-off SwiftUI scale modifier.

## Current Asset Audit

Run:

```sh
make validate-home-assets
```

Current production metadata after the 2026-08-23 artwork update:

| Tile | Path | Dimensions | Aspect Ratio | Format | Color Profile | Alpha | Source Geometry |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Notation Training | `ChessNotation/Assets.xcassets/TileNotationTraining.imageset/TileNotationTraining.png` | 1422 x 1106 | 9:7 | PNG | unmanaged RGB | false | Canonical |
| Timed Training | `ChessNotation/Assets.xcassets/TileTimedNotation.imageset/TileTimedNotation.png` | 1422 x 1106 | 9:7 | PNG | unmanaged RGB | false | Canonical |
| Board Skills / Square Recognition | `ChessNotation/Assets.xcassets/TileSquareRecognition.imageset/TileSquareRecognition.png` | 1422 x 1106 | 9:7 | PNG | unmanaged RGB | false | Canonical |
| Position Recall | `ChessNotation/Assets.xcassets/TilePositionRecall.imageset/TilePositionRecall.png` | 1422 x 1106 | 9:7 | PNG | unmanaged RGB | false | Canonical |
| Instructions | `ChessNotation/Assets.xcassets/TileInstructions.imageset/TileInstructions.png` | 1422 x 1106 | 9:7 | PNG | unmanaged RGB | false | Canonical |

Matching source dimensions remove the old aspect-ratio mismatch, but perceived scale, focal placement, and crop quality still require rendered screenshot review. Metadata validation alone does not prove visual acceptance.

## Replacement Instructions

For any future Home tile replacement:

1. Create or export a 1422 x 1106 px PNG.
2. Use RGB with no alpha channel.
3. Either leave the RGB image unmanaged or embed an sRGB-compatible profile; do not embed a conflicting color profile.
4. Keep important subject content inside the 994 x 840 safe region where practical.
5. Center the visual mass around x = 711, y = 531 unless a documented composition requires a small optical offset.
6. Preserve full-bleed background to all canvas edges.
7. Avoid baked text, borders, rounded corners, arrows, shadows, or UI chrome.
8. Run `make validate-home-assets`.
9. Capture and review the required CN-SPEC-0027 device screenshot matrix before claiming visual completion.

The repository normalizer remains available for future inconsistent source material, but already-canonical 1422 x 1106 RGB assets are treated as normalized and are not rewritten solely to add ICC metadata.

Do not adjust SwiftUI per-card scale to compensate for source art. If a future asset still needs focal adjustment after source normalization, add a documented shared focal-point or inset mechanism with regression coverage.
