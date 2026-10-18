"""Imported animation data integrity; visual quality still requires Studio."""
import hashlib
import json
import math
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MotionAssetsTest(unittest.TestCase):
    def test_new_locomotion_source_and_clips(self):
        base = ROOT / "assets/animations/quaternius-locomotion"
        manifest = json.loads((base / "manifest.json").read_text())
        self.assertEqual(manifest["license"], "CC0-1.0")
        self.assertEqual(hashlib.sha256((ROOT / manifest["originalGLB"]).read_bytes()).hexdigest(), manifest["originalGLBSHA256"])
        self.assertEqual({c["name"] for c in manifest["clips"]}, {"Walk_Loop", "Jog_Fwd_Loop", "Jump_Start", "Jump_Loop", "Jump_Land", "Roll"})
        for clip in manifest["clips"]:
            data = (ROOT / clip["file"]).read_bytes()
            self.assertEqual(hashlib.sha256(data).hexdigest(), clip["sha256"])
            rows = re.findall(r"^\{([\d,\-]+)\},$", data.decode(), re.MULTILINE)
            self.assertEqual(len(rows), clip["frames"])
            self.assertEqual(len(rows), math.ceil(clip["duration"] * 60) + 1)
            for row in rows:
                numbers = [int(n) for n in row.split(",")]
                self.assertEqual(len(numbers), 48)
                self.assertEqual(numbers[:3], [0, 0, 0], "Humanoid owns translation")
            self.assertGreater(len(set(rows)), 5, "Not a static or placeholder clip")

    def test_provenance_and_r15_frame_shape(self):
        manifest = json.loads((ROOT / "assets/animations/manifest.json").read_text())
        self.assertEqual(manifest["license"], "CC0-1.0")
        self.assertEqual(len(manifest["clips"]), 4)
        for clip in manifest["clips"]:
            with self.subTest(clip=clip["name"]):
                data = (ROOT / clip["file"]).read_bytes()
                self.assertEqual(hashlib.sha256(data).hexdigest(), clip["sha256"])
                rows = re.findall(r"^\{([\d,\-]+)\},$", data.decode(), re.MULTILINE)
                self.assertGreater(len(rows), 10)
                for row in rows:
                    numbers = [int(n) for n in row.split(",")]
                    self.assertEqual(len(numbers), 48, "XYZ root plus 15 R15 joint rotations")
                    self.assertTrue(all(math.isfinite(n) for n in numbers))
                    self.assertEqual((numbers[0], numbers[2]), (0, 0), "No horizontal root motion")
