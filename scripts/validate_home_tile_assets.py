#!/usr/bin/env python3
"""Validate Home tile artwork metadata.

Run with the repository virtualenv when available:

    .venv/bin/python scripts/validate_home_tile_assets.py
"""

from __future__ import annotations

import argparse
import io
import re
import sys
from dataclasses import dataclass
from pathlib import Path

try:
    from PIL import Image, ImageCms
except ImportError:  # pragma: no cover - exercised by local setup, not tests.
    print(
        "Pillow is required. Run `.venv/bin/python -m pip install Pillow` "
        "or execute with a virtualenv that already includes Pillow.",
        file=sys.stderr,
    )
    raise SystemExit(2)


EXPECTED_WIDTH = 1422
EXPECTED_HEIGHT = 1106
EXPECTED_FORMAT = "PNG"
ALLOWED_MODES = {"RGB"}

REQUIRED_ASSETS = {
    "notationTrainingTile": "TileNotationTraining",
    "timedNotationTile": "TileTimedNotation",
    "squareRecognitionTile": "TileSquareRecognition",
    "positionRecallTile": "TilePositionRecall",
    "instructionsTile": "TileInstructions",
}


@dataclass(frozen=True)
class AssetMetadata:
    path: Path
    width: int
    height: int
    image_format: str | None
    mode: str
    color_profile: str
    has_alpha: bool

    @property
    def aspect_ratio(self) -> float:
        return self.width / self.height


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate normalized Home tile assets.")
    parser.add_argument(
        "--assets-root",
        default="ChessNotation/Assets.xcassets",
        help="Path to Assets.xcassets from the repository root.",
    )
    parser.add_argument(
        "--premium-design-source",
        default="ChessNotation/Features/Home/PremiumDesign.swift",
        help="Swift source containing PremiumAssetName constants.",
    )
    args = parser.parse_args()

    assets_root = Path(args.assets_root)
    failures: list[str] = []
    failures.extend(validate_premium_asset_mapping(Path(args.premium_design_source)))

    image_names = list(REQUIRED_ASSETS.values())
    duplicates = sorted({name for name in image_names if image_names.count(name) > 1})
    for name in duplicates:
        failures.append(f"duplicate file mapping for {name}")

    for label, image_name in REQUIRED_ASSETS.items():
        path = assets_root / f"{image_name}.imageset" / f"{image_name}.png"
        metadata, asset_failures = validate_asset(path)
        status = "OK" if not asset_failures else "FAIL"

        if metadata is None:
            print(f"{status} {label}: {path} missing")
        else:
            print(
                f"{status} {label}: {metadata.path} "
                f"{metadata.width}x{metadata.height} "
                f"aspect={metadata.aspect_ratio:.4f} "
                f"format={metadata.image_format or 'unknown'} "
                f"profile={metadata.color_profile} "
                f"mode={metadata.mode} "
                f"alpha={metadata.has_alpha}"
            )

        failures.extend(f"{label}: {failure}" for failure in asset_failures)

    if failures:
        print("\nHome tile asset validation failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    return 0


def validate_premium_asset_mapping(source_path: Path) -> list[str]:
    if not source_path.exists():
        return [f"missing PremiumAssetName source: {source_path}"]

    source = source_path.read_text(encoding="utf-8")
    constants = dict(re.findall(r"static\s+let\s+(\w+)\s*=\s*\"([^\"]+)\"", source))
    failures: list[str] = []
    observed_values: list[str] = []

    for constant_name, expected_value in REQUIRED_ASSETS.items():
        actual_value = constants.get(constant_name)
        if actual_value is None:
            failures.append(f"missing PremiumAssetName.{constant_name}")
            continue
        observed_values.append(actual_value)
        if actual_value != expected_value:
            failures.append(
                f"PremiumAssetName.{constant_name} expected {expected_value}, found {actual_value}"
            )

    duplicates = sorted({value for value in observed_values if observed_values.count(value) > 1})
    for value in duplicates:
        failures.append(f"duplicate PremiumAssetName tile mapping for {value}")

    return failures


def validate_asset(path: Path) -> tuple[AssetMetadata | None, list[str]]:
    if not path.exists():
        return None, ["missing file"]

    failures: list[str] = []
    try:
        metadata = read_metadata(path)
    except OSError as error:
        return None, [f"could not read image: {error}"]

    if metadata.image_format != EXPECTED_FORMAT:
        failures.append(f"expected {EXPECTED_FORMAT} format, found {metadata.image_format or 'unknown'}")
    if metadata.width != EXPECTED_WIDTH or metadata.height != EXPECTED_HEIGHT:
        failures.append(
            f"expected {EXPECTED_WIDTH}x{EXPECTED_HEIGHT}, found {metadata.width}x{metadata.height}"
        )
    if metadata.mode not in ALLOWED_MODES:
        failures.append(f"unsupported mode {metadata.mode}; expected one of {sorted(ALLOWED_MODES)}")
    if metadata.has_alpha:
        failures.append("unexpected alpha channel or transparency")
    if not is_color_profile_compatible(metadata.color_profile):
        failures.append(
            "expected sRGB-compatible embedded profile or unmanaged RGB, "
            f"found {metadata.color_profile}"
        )

    return metadata, failures


def read_metadata(path: Path) -> AssetMetadata:
    with Image.open(path) as image:
        image.load()
        return AssetMetadata(
            path=path,
            width=image.width,
            height=image.height,
            image_format=image.format,
            mode=image.mode,
            color_profile=color_profile_name(image),
            has_alpha=has_alpha(image),
        )


def color_profile_name(image: Image.Image) -> str:
    if "icc_profile" in image.info:
        profile = image.info.get("icc_profile")
        if isinstance(profile, bytes):
            try:
                profile_name = ImageCms.getProfileName(ImageCms.ImageCmsProfile(io.BytesIO(profile))).strip()
            except ImageCms.PyCMSError:
                return "embedded ICC"
            if "srgb" in profile_name.lower():
                return profile_name
            return "embedded ICC"
        return "embedded ICC"
    if "srgb" in image.info:
        return "sRGB"
    if image.mode == "RGB":
        return "unmanaged RGB"
    return "unmanaged"


def is_color_profile_compatible(profile_name: str) -> bool:
    normalized = profile_name.strip().lower()
    return normalized == "unmanaged rgb" or "srgb" in normalized


def has_alpha(image: Image.Image) -> bool:
    if image.mode in {"LA", "RGBA"}:
        return True
    if image.mode == "P" and "transparency" in image.info:
        return True
    return "transparency" in image.info


if __name__ == "__main__":
    raise SystemExit(main())
