import re
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from build_installer import ROOT, build, modules_for, source_literal


class InstallerTests(unittest.TestCase):
    def test_all_modules_packaged_before_entry_is_parented(self):
        output = build()
        for side, container in (("server", "game.ServerScriptService"),
                                ("client", "game.StarterPlayer.StarterPlayerScripts")):
            for path in modules_for(ROOT, side):
                marker = "-- Source: " + path.relative_to(ROOT).as_posix()
                self.assertEqual(output.count(marker), 1)
                self.assertLess(output.index(marker), output.index("entry.Parent=" + container))
                self.assertIn(source_literal(path.read_text(encoding="utf-8")), output)

    def test_delimiter_collision_preserves_source(self):
        source = '-- embedded ]====] and ]=====]\nreturn "한글"\n'
        literal = source_literal(source)
        match = re.match(r"\[(=*)\[\n", literal)
        closing = "]" + match[1] + "]"
        self.assertNotIn(closing, source)
        self.assertEqual(literal[match.end():-len(closing)], source)

    def test_module_folder_collision_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            base = root / "src/server"
            (base / "combat").mkdir(parents=True)
            (base / "combat.luau").write_text("return {}")
            (base / "combat/Spell.luau").write_text("return {}")
            with self.assertRaisesRegex(ValueError, "collision"):
                modules_for(root, "server")

    def test_missing_module_tree_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaisesRegex(ValueError, "No server modules"):
                modules_for(Path(temp), "server")

    def test_generated_output_is_deterministic_and_current(self):
        self.assertEqual(build(), build())
        self.assertEqual(build(), (ROOT / "install.luau").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
