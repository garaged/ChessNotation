import tempfile
import unittest
import sys
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from pathlib import Path
from unittest.mock import patch

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import validate_home_tile_assets as validator


class HomeTileAssetValidatorTests(unittest.TestCase):
    def test_valid_asset_passes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new("RGB", (1600, 1000), (12, 34, 56)).save(path, format="PNG", icc_profile=b"sRGB")

            metadata, failures = validator.validate_asset(path)

            self.assertIsNotNone(metadata)
            self.assertEqual(failures, [])

    def test_wrong_dimensions_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new("RGB", (1422, 1106), (12, 34, 56)).save(path, format="PNG", icc_profile=b"sRGB")

            _, failures = validator.validate_asset(path)

            self.assertIn("expected 1600x1000, found 1422x1106", failures)

    def test_alpha_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Tile.png"
            Image.new("RGBA", (1600, 1000), (12, 34, 56, 255)).save(path, format="PNG", icc_profile=b"sRGB")

            _, failures = validator.validate_asset(path)

            self.assertIn("unexpected alpha channel or transparency", failures)

    def test_missing_file_fails(self):
        metadata, failures = validator.validate_asset(Path("missing.png"))

        self.assertIsNone(metadata)
        self.assertEqual(failures, ["missing file"])

    def test_duplicate_required_mapping_fails_main(self):
        with tempfile.TemporaryDirectory() as directory:
            assets_root = Path(directory)
            imageset = assets_root / "Shared.imageset"
            imageset.mkdir()
            Image.new("RGB", (1600, 1000), (12, 34, 56)).save(
                imageset / "Shared.png",
                format="PNG",
                icc_profile=b"sRGB",
            )

            with patch.object(validator, "REQUIRED_ASSETS", {"one": "Shared", "two": "Shared"}):
                with patch("sys.argv", ["validate_home_tile_assets.py", "--assets-root", str(assets_root)]):
                    with redirect_stdout(StringIO()), redirect_stderr(StringIO()):
                        result = validator.main()

            self.assertEqual(result, 1)


if __name__ == "__main__":
    unittest.main()
