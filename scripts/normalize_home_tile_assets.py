#!/usr/bin/env python3
"""Normalize production Home tile artwork to the CN-SPEC-0027 contract."""

from __future__ import annotations

import argparse
import hashlib
import shutil
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

try:
    from PIL import Image, ImageCms, ImageDraw, ImageFilter, ImageOps
except ImportError:  # pragma: no cover - local setup failure.
    print(
        "Pillow is required. Run `.venv/bin/python -m pip install Pillow` "
        "or execute with a virtualenv that already includes Pillow.",
        file=sys.stderr,
    )
    raise SystemExit(2)


CANVAS_SIZE = (1600, 1000)
SAFE_MARGIN_X = 240
SAFE_MARGIN_Y = 120
OPTICAL_CENTER = (800, 480)
ASSETS_ROOT = Path("ChessNotation/Assets.xcassets")
CONTACT_SHEET_DIR = Path(tempfile.gettempdir()) / "ChessNotation-home-tile-normalization"
SRGB_PROFILE_BYTES = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()


@dataclass(frozen=True)
class TileProfile:
    label: str
    image_name: str
    foreground_width_ratio: float
    optical_center: tuple[int, int] = OPTICAL_CENTER
    background_fill_scale: float = 1.06

    @property
    def path(self) -> Path:
        return ASSETS_ROOT / f"{self.image_name}.imageset" / f"{self.image_name}.png"


PROFILES: tuple[TileProfile, ...] = (
    TileProfile("Notation Training", "TileNotationTraining", 0.60),
    TileProfile("Timed Training", "TileTimedNotation", 0.58),
    TileProfile("Board Skills / Square Recognition", "TileSquareRecognition", 0.52),
    TileProfile("Position Recall", "TilePositionRecall", 0.47, optical_center=(845, 480), background_fill_scale=1.12),
    TileProfile("Instructions", "TileInstructions", 0.60),
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Normalize Home tile assets to 1600x1000 PNGs.")
    parser.add_argument("--dry-run", action="store_true", help="Print work without writing production assets.")
    parser.add_argument("--output-dir", type=Path, help="Write review copies to this directory instead of production.")
    parser.add_argument(
        "--contact-sheet-dir",
        type=Path,
        default=CONTACT_SHEET_DIR,
        help="Directory for generated contact sheets.",
    )
    args = parser.parse_args()

    output_dir: Path | None = args.output_dir
    contact_sheet_dir: Path = args.contact_sheet_dir

    try:
        results = normalize_all(dry_run=args.dry_run, output_dir=output_dir)
    except NormalizationError as error:
        print(f"Home tile normalization failed: {error}", file=sys.stderr)
        return 1

    for result in results:
        action = "would write" if args.dry_run else "wrote"
        print(
            f"{result.profile.label}: {result.source_path} "
            f"{result.source_size[0]}x{result.source_size[1]} -> "
            f"{result.output_path} {result.output_size[0]}x{result.output_size[1]} "
            f"profileScale={result.profile.foreground_width_ratio:.2f} "
            f"center={result.profile.optical_center} {action}"
        )

    if not args.dry_run:
        normalized_paths = [result.output_path for result in results]
        write_contact_sheets(normalized_paths, contact_sheet_dir)
        print(f"Contact sheets: {contact_sheet_dir}")

    return 0


@dataclass(frozen=True)
class NormalizationResult:
    profile: TileProfile
    source_path: Path
    output_path: Path
    source_size: tuple[int, int]
    output_size: tuple[int, int]


def normalize_all(dry_run: bool = False, output_dir: Path | None = None) -> list[NormalizationResult]:
    paths = [profile.path for profile in PROFILES]
    missing = [str(path) for path in paths if not path.exists()]
    if missing:
        raise NormalizationError("missing expected asset(s): " + ", ".join(missing))

    duplicate_paths = sorted({path for path in paths if paths.count(path) > 1})
    if duplicate_paths:
        raise NormalizationError("duplicate output mapping: " + ", ".join(str(path) for path in duplicate_paths))

    backup_dir = Path(tempfile.mkdtemp(prefix="ChessNotation-home-tile-originals-"))
    results: list[NormalizationResult] = []

    for profile in PROFILES:
        source_path = profile.path
        output_path = review_output_path(output_dir, profile) if output_dir else source_path
        if output_dir and not dry_run:
            output_path.parent.mkdir(parents=True, exist_ok=True)

        with Image.open(source_path) as source:
            source.load()
            source_size = source.size
            normalized = normalize_image(source, profile)

        if not dry_run and output_dir is None:
            shutil.copy2(source_path, backup_dir / source_path.name)

        if not dry_run:
            write_if_changed(normalized, output_path)

        results.append(
            NormalizationResult(
                profile=profile,
                source_path=source_path,
                output_path=output_path,
                source_size=source_size,
                output_size=normalized.size,
            )
        )

    if not dry_run and output_dir is None:
        print(f"Temporary originals preserved at: {backup_dir}")

    return results


def normalize_image(source: Image.Image, profile: TileProfile) -> Image.Image:
    source_rgb = flatten_to_rgb(source)
    if source_rgb.size == CANVAS_SIZE and is_rgb_without_alpha(source_rgb):
        return source_rgb

    background = make_extended_background(source_rgb, profile.background_fill_scale)
    foreground = make_foreground(source_rgb, profile.foreground_width_ratio)

    canvas = background.copy()
    paste_x = int(round(profile.optical_center[0] - foreground.width / 2))
    paste_y = int(round(profile.optical_center[1] - foreground.height / 2))
    canvas.paste(foreground, (paste_x, paste_y))
    return canvas.convert("RGB")


def flatten_to_rgb(image: Image.Image) -> Image.Image:
    if image.mode == "RGB":
        return image.copy()
    if image.mode in {"RGBA", "LA"} or "transparency" in image.info:
        rgba = image.convert("RGBA")
        background = Image.new("RGBA", rgba.size, (0, 0, 0, 255))
        return Image.alpha_composite(background, rgba).convert("RGB")
    return image.convert("RGB")


def make_extended_background(image: Image.Image, fill_scale: float) -> Image.Image:
    scale = max(CANVAS_SIZE[0] / image.width, CANVAS_SIZE[1] / image.height) * fill_scale
    resized = image.resize(
        (max(1, int(round(image.width * scale))), max(1, int(round(image.height * scale)))),
        Image.Resampling.LANCZOS,
    )
    fitted = ImageOps.fit(
        resized,
        CANVAS_SIZE,
        method=Image.Resampling.LANCZOS,
        centering=(0.5, 0.48),
    )
    return fitted.filter(ImageFilter.GaussianBlur(radius=28))


def make_foreground(image: Image.Image, width_ratio: float) -> Image.Image:
    target_width = int(round(CANVAS_SIZE[0] * width_ratio))
    max_height = CANVAS_SIZE[1] - (SAFE_MARGIN_Y * 2)
    scale = min(target_width / image.width, max_height / image.height)
    target_size = (
        max(1, int(round(image.width * scale))),
        max(1, int(round(image.height * scale))),
    )
    return image.resize(target_size, Image.Resampling.LANCZOS)


def write_if_changed(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    existing_hash = file_hash(path) if path.exists() else None
    temp_path = path.with_suffix(path.suffix + ".tmp")
    image.save(temp_path, format="PNG", optimize=True, compress_level=9, icc_profile=SRGB_PROFILE_BYTES)
    new_hash = file_hash(temp_path)
    if existing_hash == new_hash:
        temp_path.unlink()
        return
    temp_path.replace(path)


def write_contact_sheets(paths: list[Path], output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    images = [Image.open(path).convert("RGB") for path in paths]
    labels = [profile.label for profile in PROFILES]
    try:
        write_contact_sheet(images, labels, output_dir / "home-tile-normalization-contact-sheet.png", draw_guides=True)
        write_contact_sheet(images, labels, output_dir / "home-tile-card-artwork-contact-sheet.png", draw_guides=False)
    finally:
        for image in images:
            image.close()


def write_contact_sheet(images: list[Image.Image], labels: list[str], path: Path, draw_guides: bool) -> None:
    tile_w, tile_h = CANVAS_SIZE
    label_h = 52
    cols = 2
    rows = 3
    sheet = Image.new("RGB", (cols * tile_w, rows * (tile_h + label_h)), (22, 24, 28))
    draw = ImageDraw.Draw(sheet)
    for index, (image, label) in enumerate(zip(images, labels)):
        col = index % cols
        row = index // cols
        x = col * tile_w
        y = row * (tile_h + label_h)
        sheet.paste(image, (x, y + label_h))
        draw.text((x + 24, y + 16), label, fill=(240, 240, 240))
        if draw_guides:
            safe_box = (
                x + SAFE_MARGIN_X,
                y + label_h + SAFE_MARGIN_Y,
                x + tile_w - SAFE_MARGIN_X,
                y + label_h + tile_h - SAFE_MARGIN_Y,
            )
            draw.rectangle(safe_box, outline=(255, 220, 70), width=3)
            draw.line((x + 800, y + label_h, x + 800, y + label_h + tile_h), fill=(255, 220, 70), width=1)
            draw.line((x, y + label_h + 480, x + tile_w, y + label_h + 480), fill=(255, 220, 70), width=1)
    sheet.save(path, format="PNG", optimize=True, compress_level=9)


def review_output_path(output_dir: Path | None, profile: TileProfile) -> Path:
    if output_dir is None:
        return profile.path
    return output_dir / f"{profile.image_name}.png"


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def is_rgb_without_alpha(image: Image.Image) -> bool:
    return image.mode == "RGB" and image.size == CANVAS_SIZE


class NormalizationError(Exception):
    pass


if __name__ == "__main__":
    raise SystemExit(main())
