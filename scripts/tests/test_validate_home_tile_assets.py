import tempfile
import unittest
import sys
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from unittest.mock import patch

from PIL import Image, ImageCms

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import validate_home_tile_assets as validator


SRGB_PROFILE_BYTES = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()


class HomeTileAssetValidatorTests(unittest.TestCase):
    def test_valid_unmanaged_rgb_asset_passes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new(
                "RGB",
                (validator.EXPECTED_WIDTH, validator.EXPECTED_HEIGHT),
                (12, 34, 56),
            ).save(path, format="PNG")

            metadata, failures = validator.validate_asset(path)

            self.assertIsNotNone(metadata)
            self.assertEqual(metadata.color_profile, "unmanaged RGB")
            self.assertEqual(failures, [])

    def test_valid_srgb_asset_passes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new(
                "RGB",
                (validator.EXPECTED_WIDTH, validator.EXPECTED_HEIGHT),
                (12, 34, 56),
            ).save(
                path,
                format="PNG",
                icc_profile=SRGB_PROFILE_BYTES,
            )

            metadata, failures = validator.validate_asset(path)

            self.assertIsNotNone(metadata)
            self.assertEqual(failures, [])

    def test_wrong_dimensions_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new("RGB", (1600, 1000), (12, 34, 56)).save(path, format="PNG")

            _, failures = validator.validate_asset(path)

            self.assertIn(
                f"expected {validator.EXPECTED_WIDTH}x{validator.EXPECTED_HEIGHT}, found 1600x1000",
                failures,
            )

    def test_alpha_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new(
                "RGBA",
                (validator.EXPECTED_WIDTH, validator.EXPECTED_HEIGHT),
                (12, 34, 56, 255),
            ).save(path, format="PNG")

            _, failures = validator.validate_asset(path)

            self.assertIn("unexpected alpha channel or transparency", failures)

    def test_incompatible_embedded_profile_fails(self):
        metadata = validator.AssetMetadata(
            path=Path("Tile.png"),
            width=validator.EXPECTED_WIDTH,
            height=validator.EXPECTED_HEIGHT,
            image_format="PNG",
            mode="RGB",
            color_profile="embedded ICC",
            has_alpha=False,
        )

        with patch.object(validator, "read_metadata", return_value=metadata):
            _, failures = validator.validate_asset(Path("Tile.png"))

        self.assertIn(
            "expected sRGB-compatible embedded profile or unmanaged RGB, found embedded ICC",
            failures,
        )

    def test_missing_file_fails(self):
        metadata, failures = validator.validate_asset(Path("missing.png"))

        self.assertIsNone(metadata)
        self.assertEqual(failures, ["missing file"])

    def test_premium_asset_mapping_mismatch_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "PremiumDesign.swift"
            source.write_text(
                """
                enum PremiumAssetName {
                    static let notationTrainingTile = "TileNotationTraining"
                    static let timedNotationTile = "WrongTile"
                    static let squareRecognitionTile = "TileSquareRecognition"
                    static let positionRecallTile = "TilePositionRecall"
                    static let instructionsTile = "TileInstructions"
                }
                """,
                encoding="utf-8",
            )

            failures = validator.validate_premium_asset_mapping(source)

            self.assertIn(
                "PremiumAssetName.timedNotationTile expected TileTimedNotation, found WrongTile",
                failures,
            )

    def test_duplicate_required_mapping_fails_main(self):
        with tempfile.TemporaryDirectory() as directory:
            assets_root = Path(directory)
            imageset = assets_root / "Shared.imageset"
            imageset.mkdir()
            Image.new(
                "RGB",
                (validator.EXPECTED_WIDTH, validator.EXPECTED_HEIGHT),
                (12, 34, 56),
            ).save(imageset / "Shared.png", format="PNG")

            premium_source = Path(directory) / "PremiumDesign.swift"
            premium_source.write_text("enum PremiumAssetName {}", encoding="utf-8")

            with patch.object(validator, "REQUIRED_ASSETS", {"one": "Shared", "two": "Shared"}):
                with patch(
                    "sys.argv",
                    [
                        "validate_home_tile_assets.py",
                        "--assets-root",
                        str(assets_root),
                        "--premium-design-source",
                        str(premium_source),
                    ],
                ):
                    with redirect_stdout(StringIO()), redirect_stderr(StringIO()):
                        result = validator.main()

            self.assertEqual(result, 1)


if __name__ == "__main__":
    unittest.main()
