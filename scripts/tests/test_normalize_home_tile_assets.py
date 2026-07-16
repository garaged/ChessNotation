import hashlib
import tempfile
import unittest
import sys
from pathlib import Path
from unittest.mock import patch

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import normalize_home_tile_assets as normalizer


class HomeTileAssetNormalizerTests(unittest.TestCase):
    def test_landscape_input_normalizes_to_target_canvas(self):
        image = Image.new("RGB", (2000, 900), (80, 90, 100))

        output = normalizer.normalize_image(image, normalizer.PROFILES[0])

        self.assertEqual(output.size, normalizer.CANVAS_SIZE)
        self.assertEqual(output.mode, "RGB")

    def test_portrait_input_normalizes_to_target_canvas(self):
        image = Image.new("RGB", (700, 1400), (80, 90, 100))

        output = normalizer.normalize_image(image, normalizer.PROFILES[0])

        self.assertEqual(output.size, normalizer.CANVAS_SIZE)
        self.assertEqual(output.mode, "RGB")

    def test_square_input_normalizes_to_target_canvas(self):
        image = Image.new("RGB", (900, 900), (80, 90, 100))

        output = normalizer.normalize_image(image, normalizer.PROFILES[0])

        self.assertEqual(output.size, normalizer.CANVAS_SIZE)
        self.assertEqual(output.mode, "RGB")

    def test_already_normalized_input_is_not_rescaled(self):
        image = Image.new("RGB", normalizer.CANVAS_SIZE, (12, 34, 56))
        image.putpixel((100, 120), (240, 10, 20))

        output = normalizer.normalize_image(image, normalizer.PROFILES[0])

        self.assertEqual(output.size, normalizer.CANVAS_SIZE)
        self.assertEqual(output.tobytes(), image.tobytes())

    def test_alpha_input_is_flattened_to_rgb(self):
        image = Image.new("RGBA", (1000, 600), (12, 34, 56, 128))

        output = normalizer.normalize_image(image, normalizer.PROFILES[0])

        self.assertEqual(output.mode, "RGB")

    def test_foreground_resize_preserves_source_aspect_ratio(self):
        image = Image.new("RGB", (1200, 600), (12, 34, 56))

        foreground = normalizer.make_foreground(image, 0.60)

        self.assertAlmostEqual(foreground.width / foreground.height, 2.0, places=3)

    def test_output_encoding_is_deterministic(self):
        image = Image.new("RGB", (1200, 900), (12, 34, 56))
        output = normalizer.normalize_image(image, normalizer.PROFILES[0])

        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.png"
            second = Path(directory) / "second.png"
            normalizer.write_if_changed(output, first)
            normalizer.write_if_changed(output, second)

            self.assertEqual(sha256(first), sha256(second))

    def test_missing_asset_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(normalizer, "ASSETS_ROOT", Path(directory)):
                with self.assertRaises(normalizer.NormalizationError):
                    normalizer.normalize_all(dry_run=True)

    def test_position_recall_profile_uses_lower_foreground_scale(self):
        profiles = {profile.image_name: profile for profile in normalizer.PROFILES}
        position_recall = profiles["TilePositionRecall"].foreground_width_ratio

        self.assertLess(position_recall, profiles["TileNotationTraining"].foreground_width_ratio)
        self.assertLess(position_recall, profiles["TileTimedNotation"].foreground_width_ratio)
        self.assertLess(position_recall, profiles["TileInstructions"].foreground_width_ratio)
        self.assertLess(position_recall, profiles["TileSquareRecognition"].foreground_width_ratio)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


if __name__ == "__main__":
    unittest.main()
