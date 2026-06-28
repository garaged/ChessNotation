# CN-SPEC-0013: Premium Rendered Artwork Quality

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

ChessNotation should use high-quality chess-specific artwork that is visually
close to the provided mock: cinematic, tactile, dark, premium, and materially
rich. The main-screen tiles, board textures, and chess pieces should look like
they belong to the same designed product rather than a mix of generic icons,
flat symbols, and placeholder textures.

This spec defines the production quality bar for generated or handcrafted bitmap
assets used by the premium redesign. CN-SPEC-0011 defines the required asset
inventory and baseline prompts. This spec strengthens those requirements with
material direction, lighting rules, prompt refinements, board/piece style, export
criteria, and visual acceptance gates.

## Scope

In scope:

- High-quality artwork for all Home main-screen tiles.
- High-quality hero artwork and library random-game artwork.
- Board texture assets used in backgrounds, tiles, thumbnails, and game areas.
- Piece visual direction for rendered bitmap artwork.
- Prompt requirements for textures, shadows, materials, composition, and safe
  text overlay regions.
- Asset export, naming, review, and replacement criteria.
- Visual consistency requirements across Home, Game Library, Notation Game,
  Square Recognition, Results, Instructions, and Settings.

Out of scope:

- Changing chess rules, SAN validation, or game-selection behavior.
- Replacing functional in-app boards with static screenshots.
- App icon redesign.
- App Store marketing screenshots.
- Animated 3D rendering.
- Purchasing or licensing third-party chess-piece sets.

## Visual Direction

The artwork must feel like premium chess training photography or a high-end
realistic render. The target style is close to the mock:

- Dark charcoal and black environment.
- Warm gold identity lighting.
- Accent color per mode: green for practice, blue for timed, purple for square
  recognition, amber/gold for instructions.
- Tactile board surfaces with visible grain, bevels, and soft wear.
- Weighted chess pieces with realistic material response.
- Controlled vignette and directional shadows.
- Shallow depth where it helps focus, but never so blurred that the subject is
  unclear.
- No generic app-icon look, emoji look, clip-art look, flat vector look, or
  plain SF Symbol replacement as the primary visual.

Artwork may be realistic, painterly-realistic, or premium 3D-rendered, but all
assets in the same release must use one coherent style family.

## Functional Requirements

- CN-SPEC-0013-FR001: Main-screen tile artwork must use chess-specific rendered or illustrated subjects as the primary visual.
- CN-SPEC-0013-FR002: Main-screen tile artwork must include realistic texture, visible material finish, and intentional shadowing.
- CN-SPEC-0013-FR003: Main-screen tile artwork must not use generic SF Symbols, emoji, flat icons, or low-detail clip art as the primary visual.
- CN-SPEC-0013-FR004: Home tile subjects must clearly distinguish Notation Training, Timed Notation, Square Recognition, and Instructions without relying only on text labels.
- CN-SPEC-0013-FR005: Every Home tile artwork must reserve a lower-left or lower-center safe region for title and subtitle overlays.
- CN-SPEC-0013-FR006: Safe overlay regions must remain dark enough for white text and must not contain high-frequency detail behind the text.
- CN-SPEC-0013-FR007: Board texture assets must show subtle square contrast, grain, beveling or surface depth, and realistic light falloff.
- CN-SPEC-0013-FR008: Board texture assets must not be so busy that coordinates, pieces, prompts, or thumbnails become unreadable.
- CN-SPEC-0013-FR009: Rendered chess pieces in artwork must share a consistent material language across assets.
- CN-SPEC-0013-FR010: White pieces in artwork should read as ivory, warm bone, brushed gold, or pale polished stone depending on context.
- CN-SPEC-0013-FR011: Black pieces in artwork should read as glossy black wood, obsidian, or black lacquer depending on context.
- CN-SPEC-0013-FR012: Piece shadows must be physically plausible and directionally consistent within each asset.
- CN-SPEC-0013-FR013: Tile images must include a subject-scale hierarchy: primary object, secondary board/material context, then accent details.
- CN-SPEC-0013-FR014: Assets must not include readable text, logos, fake UI, app screenshots, watermarks, signatures, distorted letters, or pseudo-notation marks that look like broken text.
- CN-SPEC-0013-FR015: Assets must be generated or exported large enough for 3x iPhone display and future cropping without visible pixelation.
- CN-SPEC-0013-FR016: Image-set names must match the stable names defined by CN-SPEC-0011 unless a later accepted spec changes them.
- CN-SPEC-0013-FR017: The implementation must keep native SwiftUI fallbacks only as development fallbacks, not as the final visual target.
- CN-SPEC-0013-FR018: The final app must not ship with empty image sets for required premium artwork unless a release-blocking note explicitly marks the artwork incomplete.
- CN-SPEC-0013-FR019: Board and piece artwork must remain consistent with the app's live board colors and theme enough that screenshots do not look like unrelated products.
- CN-SPEC-0013-FR020: Visual review must include Home screenshots that show all main tiles and verify that the images look close to the mock direction.
- CN-SPEC-0013-FR021: Visual review must include at least one game-screen screenshot verifying board/piece contrast against the premium background.
- CN-SPEC-0013-FR022: Visual review must include at least one Square Recognition screenshot verifying that board decoration does not reduce tap target clarity.

## Required Asset Quality Targets

### Home Hero

- Asset name: `HomeHeroPremium`
- Minimum export: 1290x900 px
- Preferred source ratio: 43:30 or wider, with crop-safe edges.
- Quality target:
  - Cinematic chess-board scene.
  - Recognizable premium knight and king silhouettes.
  - Warm crown-like light or gold accent near the app identity area.
  - Dark negative space behind title and tagline.
  - Soft perspective board floor with realistic highlights.

### Notation Training Tile

- Asset name: `TileNotationTraining`
- Minimum export: 900x700 px
- Quality target:
  - Leather or cloth scorebook, pencil, board emboss, and warm gold details.
  - The image must communicate "reading/writing notation" without readable text.
  - Materials should include visible grain, edge highlights, and cast shadows.
  - Lower-left safe overlay region must remain calm and dark.

Prompt refinement:

```text
High-end realistic chess notation training tile artwork, dark green leather
scorebook with subtle non-readable board emboss, black-and-gold pencil crossing
the book, matte charcoal table, soft warm rim light, tiny gold dust particles,
realistic leather grain and pencil reflections, cinematic shadows, premium
mobile app artwork, lower-left dark negative space for title, no readable text,
no letters, no UI, no logo, no watermark.
```

### Timed Notation Tile

- Asset name: `TileTimedNotation`
- Minimum export: 900x700 px
- Quality target:
  - Premium stopwatch or chess clock with black enamel and gold rim.
  - Blue speed accent must feel integrated, not like generic neon decoration.
  - Motion cues must not obscure the subject.
  - Avoid readable numerals on the dial.

Prompt refinement:

```text
Luxury timed chess training tile artwork, black enamel stopwatch with polished
gold rim and crown, subtle blue motion streaks, blurred chessboard and dark
pieces in the background, charcoal and navy palette, warm gold rim lighting,
realistic glass reflections, deep shadows, premium product render, lower-left
dark negative space for title, no readable numbers, no text, no UI, no logo,
no watermark.
```

### Square Recognition Tile

- Asset name: `TileSquareRecognition`
- Minimum export: 900x700 px
- Quality target:
  - Top-down or shallow-angle board with one highlighted square.
  - A single pawn or coordinate marker may be used, but the board and square
    focus must remain the primary subject.
  - Purple accent should be atmospheric and restrained.
  - Any coordinate marks must be abstract or unreadable so the bitmap does not
    compete with app text.

Prompt refinement:

```text
Premium square recognition chess tile artwork, dark purple and charcoal
chessboard with tactile wood grain, one central square glowing warm gold,
single elegant ivory pawn standing on the highlighted square, faint abstract
rank-file guide marks around the board with no readable letters or numbers,
soft vignette, realistic shadows, high-detail premium render, lower-left dark
negative space for title, no UI, no logo, no watermark.
```

### Instructions Tile

- Asset name: `TileInstructions`
- Minimum export: 900x700 px
- Quality target:
  - Open manual or training book with blank/non-readable pages.
  - Chess pieces and pencil should feel staged like product photography.
  - Warm amber lighting should distinguish this tile from practice/timed/square
    modes.

Prompt refinement:

```text
Premium chess instruction tile artwork, open cream-page chess manual on dark
wood table, pages blank or softly lined with no readable text, small polished
chess pieces beside the book, black-and-gold pencil, warm amber side light,
realistic paper fibers and wood grain, elegant shadows, high-end training app
style, lower-left dark negative space for title, no readable writing, no UI,
no logo, no watermark.
```

### Library Random Game Artwork

- Asset name: `LibraryRandomGame`
- Minimum export: 900x360 px
- Quality target:
  - Premium die or chance object with chess-specific detail.
  - Board texture must fade to a quiet text-safe area.
  - Should read as "random game" without feeling like a casino graphic.

Prompt refinement:

```text
Premium random chess challenge banner, ivory die with subtle chess-piece pips
resting on a dark matte chessboard, warm gold side light, shallow depth, board
texture fading into clean black space on the right, realistic shadows, elegant
high-detail render for a mobile app row, no readable text, no UI, no logo,
no watermark.
```

### Shared Board Texture

- Asset name: `DarkBoardTexture`
- Minimum export: 900x900 px
- Quality target:
  - Low-contrast seamless or crop-safe board texture.
  - Fine grain and soft bevels visible at low opacity.
  - No strong piece silhouettes, no repeated obvious artifacts, no bright center
    hotspot unless a consuming view explicitly needs it.

Prompt refinement:

```text
Premium dark chessboard material texture, matte black and charcoal wood squares,
subtle bevels between squares, fine surface grain, low-contrast directional
lighting, crop-safe seamless-feeling background, no chess pieces, no text,
no logo, no watermark, suitable behind bright mobile app UI.
```

## Board and Piece Rendering Direction

When bitmap artwork includes boards or pieces, it must follow these rules:

- Boards:
  - Use dark walnut, ebony, charcoal leather, or matte stone materials.
  - Keep square contrast restrained, usually 8-18 percent luminance difference.
  - Use bevels, grain, and wear sparingly to avoid visual noise.
  - Edges may catch warm gold highlights.
  - Avoid perfectly flat checkerboards unless used only as a fallback.

- White pieces:
  - Prefer ivory, warm stone, or champagne-gold material.
  - Use visible bevels and soft specular highlights.
  - Avoid pure white plastic or emoji-like flat shapes.

- Black pieces:
  - Prefer black lacquer, dark wood, or obsidian material.
  - Preserve silhouette separation against the dark background using rim light.
  - Avoid losing black pieces into the background.

- Shadows:
  - Use soft contact shadows under pieces and objects.
  - Direction must match the asset's key light.
  - Long dramatic shadows are allowed only if they do not interfere with overlay
    text or board readability.

## Export and Asset Catalog Requirements

- Required images must be delivered as PNG or HEIC-compatible raster assets.
- Do not commit images with visible generation artifacts, broken geometry,
  unreadable fake letters, malformed chess pieces, duplicated limbs, or warped
  boards.
- Prefer 1x source images with enough pixel density for Xcode scaling, unless
  the asset pipeline explicitly creates 1x/2x/3x variants.
- Image sets must keep stable names:
  - `HomeHeroPremium.imageset`
  - `TileNotationTraining.imageset`
  - `TileTimedNotation.imageset`
  - `TileSquareRecognition.imageset`
  - `TileInstructions.imageset`
  - `LibraryRandomGame.imageset`
  - `DarkBoardTexture.imageset`
- If multiple candidate generations exist, only the accepted final image should
  be referenced by `Contents.json`.
- Rejected candidates may live outside the app target, but must not be shipped.

## Acceptance Criteria

- CN-SPEC-0013-AC001: Given Home is displayed, when each main tile is inspected, then the tile primary visual is high-quality chess-specific artwork rather than a generic icon.
- CN-SPEC-0013-AC002: Given a Home tile image is inspected, when texture and lighting are reviewed, then the image includes material detail, shadows, and a coherent premium lighting direction.
- CN-SPEC-0013-AC003: Given a Home tile title and subtitle overlay the image, when viewed on a small iPhone, then the text remains readable and does not cover the tile's primary subject.
- CN-SPEC-0013-AC004: Given the hero image is inspected, when compared with the mock direction, then it presents a dark premium chess scene with strong identity value and safe title space.
- CN-SPEC-0013-AC005: Given board texture assets are used behind UI, when text and controls are inspected, then texture adds depth without reducing readability.
- CN-SPEC-0013-AC006: Given rendered chess pieces appear in artwork, when viewed together across assets, then their material, lighting, and shadow quality feel consistent.
- CN-SPEC-0013-AC007: Given final release readiness is checked, when a required image set is empty or still using only native fallback art, then the visual asset work is considered incomplete.
- CN-SPEC-0013-AC008: Given visual screenshots are captured for Home and Game Library, when reviewed, then artwork quality is close enough to the mock that tiles and rows no longer read as placeholder UI.
- CN-SPEC-0013-AC009: Given Square Recognition is played, when board/piece styling is inspected, then premium styling does not reduce square tap clarity or prompt visibility.
- CN-SPEC-0013-AC010: Given Notation Game is played, when the board and pieces are inspected, then the board remains readable while matching the premium dark visual system.

## Coverage

- `ChessNotationTests/PremiumAssetTests.swift`: CN-SPEC-0013-AC001, CN-SPEC-0013-AC006, CN-SPEC-0013-AC007
- `ChessNotation/Assets.xcassets`: CN-SPEC-0013-AC001, CN-SPEC-0013-AC002, CN-SPEC-0013-AC004, CN-SPEC-0013-AC005, CN-SPEC-0013-AC006, CN-SPEC-0013-AC007, CN-SPEC-0013-AC008
- `ChessNotation/Features/Home/HomeView.swift`: CN-SPEC-0013-AC001, CN-SPEC-0013-AC003, CN-SPEC-0013-AC004, CN-SPEC-0013-AC008
- `ChessNotation/Features/Home/PremiumDesign.swift`: CN-SPEC-0013-AC005, CN-SPEC-0013-AC007
- `ChessNotation/Features/Game/ChessBoardView.swift`: CN-SPEC-0013-AC006, CN-SPEC-0013-AC010
- `ChessNotation/Features/Game/GameTrainingView.swift`: CN-SPEC-0013-AC010
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViews.swift`: CN-SPEC-0013-AC009

## Open Questions

- Resolved: Final assets are generated once and committed for this release.
- Resolved: The live chessboard uses custom bitmap piece art.
- Resolved: Tile assets use one universal crop for the first implementation.

## Revision Notes

- 2026-06-27: Initial proposed spec defining premium rendered artwork quality
  for main tiles, boards, pieces, textures, shadows, prompts, and acceptance
  gates.
- 2026-06-28: Accepted after asset import, live piece rendering, runtime availability tests, and coverage audit.
