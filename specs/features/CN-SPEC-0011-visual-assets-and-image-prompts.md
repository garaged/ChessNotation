# CN-SPEC-0011: Visual Assets and Image Prompts

Status: Proposed
Owner: Project
Last updated: 2026-06-27

## Intent

The premium redesign requires chess-specific visual assets that match the mock
instead of generic icons. This spec defines the required image assets, their
purpose, style constraints, prompt text, file naming, and fallback behavior.

Assets should support a dark, premium, tactile chess aesthetic with consistent
lighting, material finish, and enough negative space for overlaid text. They
should be generated or created as bitmap images only where native SwiftUI cannot
achieve the desired visual quality.

## Scope

In scope:

- Home hero artwork.
- Home mode tile artwork.
- Game Library random-game artwork.
- Optional shared texture assets.
- Image-generation prompts and asset acceptance criteria.
- Fallback rules if image generation is delayed.

Out of scope:

- Game-specific thumbnails, which are covered by CN-SPEC-0012.
- App icon redesign.
- Marketing screenshots for the App Store.
- Bottom-tab icons for unimplemented sections.

## Asset Loading and Fallback Policy

The implementation must treat missing final artwork as a visible development
fallback, not as a silent replacement of the asset requirement.

- During development, missing assets may render native SwiftUI fallbacks with
  the same layout footprint.
- Release readiness requires every required asset in this spec to exist unless a
  later accepted spec removes or replaces that asset.
- Fallbacks must be visually premium enough to keep UI tests and layout checks
  meaningful, but they must be clearly tracked as fallback implementations in
  code or tests.
- Missing assets must not collapse tile, hero, banner, or row dimensions.
- Missing assets must not remove labels, accessibility identifiers, or primary
  actions.

## Functional Requirements

- CN-SPEC-0011-FR001: The redesign must define all required non-game-specific image assets before implementation relies on them.
- CN-SPEC-0011-FR002: Required Home assets must include hero artwork, notation training tile artwork, timed notation tile artwork, square recognition tile artwork, and instructions tile artwork.
- CN-SPEC-0011-FR003: Required Game Library assets must include random filtered game artwork.
- CN-SPEC-0011-FR004: Assets must be visually consistent: dark premium chess setting, warm gold highlights, restrained green/blue/purple/orange accents, shallow depth, and realistic or high-quality illustrative materials.
- CN-SPEC-0011-FR005: Assets must leave safe space for app text overlays where the consuming view requires text over image.
- CN-SPEC-0011-FR006: Assets must not include readable text, logos, watermarks, UI controls, app screenshots, or fake interface chrome inside the bitmap.
- CN-SPEC-0011-FR007: Assets must be exported at sizes suitable for 3x iPhone display without visible pixelation.
- CN-SPEC-0011-FR008: Assets must include dark-mode contrast suitable for white or gold text overlays.
- CN-SPEC-0011-FR009: Native SwiftUI drawing may be used as a temporary fallback only if it preserves layout and does not replace the final asset requirement.
- CN-SPEC-0011-FR010: Asset filenames must be stable and descriptive so implementation and tests can reference them reliably.
- CN-SPEC-0011-FR011: Release readiness must fail or remain blocked if any required final non-game-specific asset is missing without an accepted spec change.
- CN-SPEC-0011-FR012: Missing final assets in development must render a same-size fallback that preserves all labels, actions, and accessibility identifiers.
- CN-SPEC-0011-FR013: Fallback assets must be identifiable in code or tests so they are not mistaken for final artwork.

## Required Assets and Prompts

### Hero Artwork

- Target file: `Assets.xcassets/HomeHeroPremium.imageset`
- Suggested size: 1290x900 px
- Use: Home top hero background.
- Prompt:

```text
Premium cinematic chess training scene for a mobile app hero background, dark
matte chessboard receding in perspective, golden white knight on the left,
glossy black king on the right, subtle crown-like warm light above the center,
small faint chessboard squares floating in the background, luxurious black and
deep charcoal palette with warm gold highlights, shallow depth of field,
realistic high-end product photography style, empty central space for app title,
no text, no logos, no UI, no watermark.
```

### Notation Training Tile Artwork

- Target file: `Assets.xcassets/TileNotationTraining.imageset`
- Suggested size: 900x700 px
- Use: Home tile for untimed notation practice.
- Prompt:

```text
Premium chess notation training still life, dark green leather scorebook with a
subtle chessboard emboss, black-and-gold pencil resting diagonally, a few soft
gold dust particles, dark moody background, warm side lighting, high-detail
realistic illustration, enough dark negative space near lower left for text,
no readable writing, no UI, no logo, no watermark.
```

### Timed Notation Tile Artwork

- Target file: `Assets.xcassets/TileTimedNotation.imageset`
- Suggested size: 900x700 px
- Use: Home tile for timed notation.
- Prompt:

```text
Luxury chess clock and stopwatch composition for a mobile training app tile,
round black-and-gold stopwatch angled in motion, subtle blue speed streaks,
small blurred chess pieces in background, dark navy and charcoal palette with
gold rim light, realistic premium product render, dramatic but readable,
negative space near lower left for text overlay, no numbers or readable text,
no UI, no logo, no watermark.
```

### Square Recognition Tile Artwork

- Target file: `Assets.xcassets/TileSquareRecognition.imageset`
- Suggested size: 900x700 px
- Use: Home tile for square-recognition mode.
- Prompt:

```text
Chessboard coordinate recognition concept, dark purple premium chessboard seen
from above, one central square glowing gold with a single elegant white pawn on
it, faint file and rank coordinate marks around the board but not readable text,
soft vignette, high-detail realistic illustration, tactile board materials,
negative space near lower left for text overlay, no UI, no logo, no watermark.
```

### Instructions Tile Artwork

- Target file: `Assets.xcassets/TileInstructions.imageset`
- Suggested size: 900x700 px
- Use: Home tile for instructions.
- Prompt:

```text
Open chess manual on a dark wooden table, softly lit cream pages with no
readable text, small chess pieces and notation pencil nearby, warm amber light,
premium realistic illustration, dark background, elegant training mood,
negative space near lower left for text overlay, no readable writing, no UI,
no logo, no watermark.
```

### Random Filtered Game Artwork

- Target file: `Assets.xcassets/LibraryRandomGame.imageset`
- Suggested size: 900x360 px
- Use: Game Library random filtered game row.
- Prompt:

```text
Premium random chess challenge banner, ivory die with chess-piece pips on a
dark chessboard, warm gold light, subtle board texture fading to black on the
right, elegant high-detail realistic style, enough empty space for row text and
chevron overlay, no readable text, no UI, no logo, no watermark.
```

### Shared Dark Board Texture

- Target file: `Assets.xcassets/DarkBoardTexture.imageset`
- Suggested size: 900x900 px
- Use: Low-opacity background texture for Home and Game Library.
- Prompt:

```text
Seamless dark chessboard texture, matte black and charcoal squares, subtle
surface grain, very low contrast, premium minimal background, no pieces, no
text, no logo, no watermark, suitable for overlaying bright app text.
```

## Acceptance Criteria

- CN-SPEC-0011-AC001: Given asset generation begins, when the prompts are reviewed, then every required non-game-specific asset has a target filename, purpose, suggested size, and prompt.
- CN-SPEC-0011-AC002: Given an asset is imported, when it is viewed in Home or Game Library, then it matches the dark premium chess visual direction and does not contain text, logos, watermarks, or fake UI.
- CN-SPEC-0011-AC003: Given a Home tile uses an imported asset, when title and subtitle are overlaid, then the text remains readable without covering the primary subject.
- CN-SPEC-0011-AC004: Given an asset is unavailable, when the app runs, then a native SwiftUI fallback appears with the same layout footprint and accessible controls.
- CN-SPEC-0011-AC005: Given the app renders on 3x iPhone displays, when assets are shown at their intended sizes, then they do not appear visibly pixelated.
- CN-SPEC-0011-AC006: Given release readiness is checked, when any required final asset is missing without an accepted spec change, then the release is blocked or the check fails.
- CN-SPEC-0011-AC007: Given a fallback asset is rendered during development, when implementation or tests inspect it, then it is identifiable as a fallback and does not silently satisfy final artwork requirements.

## Coverage

- Pending coverage: CN-SPEC-0011-AC001
- Pending coverage: CN-SPEC-0011-AC002
- Pending coverage: CN-SPEC-0011-AC003
- Pending coverage: CN-SPEC-0011-AC004
- Pending coverage: CN-SPEC-0011-AC005
- Pending coverage: CN-SPEC-0011-AC006
- Pending coverage: CN-SPEC-0011-AC007

## Open Questions

- Should these assets be generated once and committed, or generated through a repeatable asset pipeline script?
- Should image assets support light-mode variants, or should the premium redesign force dark presentation on these screens?
- Should generated assets be photo-realistic or painterly if the first generation pass varies in quality?

## Revision Notes

- 2026-06-27: Initial proposed spec defining premium visual assets and prompts.
- 2026-06-27: Added asset loading, fallback, and release-readiness policy.
