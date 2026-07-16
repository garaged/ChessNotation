# Home Tile Asset Normalization

CN-SPEC-0027 requires Home tile source artwork to be normalized before visual completion can be claimed.

## Target Specification

- Canvas: 1600 x 1000 px
- Aspect ratio: 8:5
- Format: PNG
- Color space: sRGB-compatible embedded profile or PNG sRGB marker
- Alpha: none expected
- No baked-in text, borders, rounded corners, arrows, shadows, or UI chrome
- Background extends to all canvas edges

Safe composition region:

- Left/right safe margin: 240 px
- Top/bottom safe margin: 120 px
- Safe content region: 1120 x 760 px
- Optical center reference: x = 800, y = 480

Recommended perceived subject scale:

- Notation Training: 58-62% of canvas width
- Timed Training: 55-60% of canvas width
- Board Skills: 48-55% of canvas width
- Position Recall: 45-52% of canvas width
- Instructions: 55-62% of canvas width

Position Recall should be composed deliberately smaller than the other gameplay tiles because its multi-piece composition has greater visual mass.

## Current Asset Audit

Run:

```sh
make validate-home-assets
```

Current metadata from 2026-07-16:

| Tile | Path | Dimensions | Aspect Ratio | Format | Color Profile | Alpha | Likely Crop Mismatch | Likely Perceived-Scale Mismatch |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Notation Training | `ChessNotation/Assets.xcassets/TileNotationTraining.imageset/TileNotationTraining.png` | 1422 x 1106 | 1.2857 | PNG | unmanaged RGB | false | Yes, source is taller/narrower than 8:5 and will crop vertically/horizontally when displayed in a fixed 8:5 frame. | Yes, subject scale cannot be compared reliably until canvas is normalized. |
| Timed Training | `ChessNotation/Assets.xcassets/TileTimedNotation.imageset/TileTimedNotation.png` | 1422 x 1106 | 1.2857 | PNG | unmanaged RGB | false | Yes, source is taller/narrower than 8:5 and will crop vertically/horizontally when displayed in a fixed 8:5 frame. | Yes, subject scale cannot be compared reliably until canvas is normalized. |
| Board Skills / Square Recognition | `ChessNotation/Assets.xcassets/TileSquareRecognition.imageset/TileSquareRecognition.png` | 1422 x 1106 | 1.2857 | PNG | unmanaged RGB | false | Yes, source is taller/narrower than 8:5 and will crop vertically/horizontally when displayed in a fixed 8:5 frame. | Yes, subject scale cannot be compared reliably until canvas is normalized. |
| Position Recall | `ChessNotation/Assets.xcassets/TilePositionRecall.imageset/TilePositionRecall.png` | 1672 x 941 | 1.7768 | PNG | unmanaged RGB | false | Yes, source is wider than 8:5 and will crop laterally when displayed in a fixed 8:5 frame. | Yes, currently appears visually larger/heavier than peer tile artwork. |
| Instructions | `ChessNotation/Assets.xcassets/TileInstructions.imageset/TileInstructions.png` | 1422 x 1106 | 1.2857 | PNG | unmanaged RGB | false | Yes, source is taller/narrower than 8:5 and will crop vertically/horizontally when displayed in a fixed 8:5 frame. | Yes, subject scale cannot be compared reliably until canvas is normalized. |

## Replacement Instructions

For each tile:

1. Create or export a 1600 x 1000 px PNG.
2. Embed an sRGB-compatible profile or write a PNG sRGB marker.
3. Flatten to RGB with no alpha channel.
4. Keep all important subject content inside the 1120 x 760 safe region.
5. Center the visual mass around x = 800, y = 480.
6. Preserve full-bleed background to all canvas edges.
7. Avoid baked text, borders, rounded corners, arrows, shadows, or UI chrome.
8. Run `make validate-home-assets`.
9. Capture and review the required CN-SPEC-0027 device screenshot matrix before claiming visual completion.

Do not adjust SwiftUI per-card scale to compensate for unnormalized source art. If a future asset still needs focal adjustment after normalization, add a documented shared focal-point or inset mechanism with regression coverage.
