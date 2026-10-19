import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from gui_model import compile_model, expression

ASSET = Path(__file__).resolve().parents[1] / "assets/ui/augment-choice.rbxmx"


class GuiModelTests(unittest.TestCase):
    def compile_tree(self, tree):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "gui.rbxmx"
            tree.write(path, encoding="unicode")
            return compile_model(path)

    def test_studio_edits_survive_packaging(self):
        tree = ET.parse(ASSET)
        text = next(item for item in tree.iter("Item")
                    if item.findtext("Properties/string[@name='Name']") == "Title")
        text.find("Properties/float[@name='TextSize']").text = "29"
        text.find("Properties/string[@name='Text']").text = "팀원의 새 디자인"
        props = text.find("Properties")
        ET.SubElement(props, "Font", name="FontFace").extend([
            ET.fromstring('<Family><url>rbxasset://fonts/families/GothamSSm.json</url></Family>'),
            ET.fromstring('<Weight>700</Weight>'), ET.fromstring('<Style>0</Style>'),
        ])
        output = self.compile_tree(tree)
        self.assertIn('["TextSize"]=29', output)
        self.assertIn('팀원의 새 디자인', output)
        self.assertIn('Font.new("rbxasset://fonts/families/GothamSSm.json"', output)
        self.assertEqual(output, self.compile_tree(tree))

    def test_scripts_and_unsupported_data_fail_instead_of_disappearing(self):
        tree = ET.parse(ASSET)
        item = ET.SubElement(tree.find("Item"), "Item", {"class": "LocalScript"})
        ET.SubElement(ET.SubElement(item, "Properties"), "string", name="Name").text = "UnsafeScript"
        with self.assertRaisesRegex(ValueError, "scripts are never allowed"):
            self.compile_tree(tree)
        tree.find("Item").remove(item)
        ET.SubElement(tree.find("Item/Properties"), "BinaryString", name="AttributesSerialize").text = "custom"
        with self.assertRaisesRegex(ValueError, "Unsupported GUI property"):
            self.compile_tree(tree)

    def test_missing_binding_slot_is_a_build_error(self):
        tree = ET.parse(ASSET)
        name = next(prop for prop in tree.iter("string") if prop.get("name") == "Name" and prop.text == "Reroll")
        name.text = "RenamedButton"
        with self.assertRaisesRegex(ValueError, "Modal/Reroll"):
            self.compile_tree(tree)

    def test_slice_and_gradient_properties(self):
        self.assertEqual(expression(ET.fromstring('<Rect2D name="SliceCenter"><min><X>12</X><Y>16</Y></min><max><X>88</X><Y>84</Y></max></Rect2D>')), 'Rect.new(12,16,88,84)')
        color = expression(ET.fromstring('<ColorSequence name="Color">0 1 0 0 0 1 0 0 1 0</ColorSequence>'))
        self.assertIn('ColorSequenceKeypoint.new(1,Color3.new(0,0,1))', color)
        self.assertEqual(expression(ET.fromstring('<Color3uint8 name="Color">4294901760</Color3uint8>')), 'Color3.fromRGB(255,0,0)')


if __name__ == "__main__":
    unittest.main()
