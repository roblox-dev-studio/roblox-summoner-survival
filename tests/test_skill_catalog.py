"""Catalog provenance, reproducibility and safe client icon fallback regressions."""
import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from build_skill_catalog import (ROOT, VERSION, MANIFEST, build_catalog, icon_helper,
                                icon_record, outputs, source_data, upload_manifest)


class SkillCatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = source_data()
        cls.catalog = build_catalog()

    def test_names_descriptions_and_roster_come_from_runtime_definitions(self):
        by_id = {item["id"]: item for item in self.catalog["skills"]}
        self.assertEqual(len(by_id), 16)
        self.assertEqual(sum(s["category"] == "auto" for s in by_id.values()), 9)
        self.assertEqual(sum(s["category"] == "active" for s in by_id.values()), 4)
        for source in self.source["auto"] + self.source["active"]:
            self.assertEqual(by_id[source["id"]]["name"], source["name"])
            self.assertEqual(by_id[source["id"]]["description"], source["desc"])
            self.assertTrue(by_id[source["id"]]["active"])
        self.assertEqual(by_id["basic"]["weaponProfile"], self.source["weapon"])
        self.assertEqual(self.catalog["loadout"]["autoSlots"], self.source["slots"])
        for item in by_id.values():
            for path in item["implementationPaths"]:
                self.assertTrue((ROOT / path).is_file(), path)

    def test_all_twenty_five_augments_match_authoritative_rules(self):
        by_id = {item["id"]: item for item in self.catalog["augments"]}
        self.assertEqual(len(by_id), 25)
        for source in self.source["augments"]:
            item = by_id[source["id"]]
            self.assertEqual(item["name"], source["name"])
            self.assertEqual(item["description"], source["desc"])
            self.assertEqual(item["rarity"], source["rarity"])
            self.assertEqual(item["cardId"], "aug_" + source["id"])
            self.assertEqual(item["parentSkill"], source.get("spell") or source.get("active"))
            self.assertEqual(item["maxStacks"], source.get("max", 1))
            self.assertEqual(item["requiresAny"], source.get("requiresAny", []))
            self.assertEqual(item["minimumParentLevel"], self.source["minimumLevels"].get(source["id"]))

    def test_twenty_two_variants_share_parent_images_with_badges(self):
        skills = {item["id"]: item for item in self.catalog["skills"]}
        dedicated = [item for item in self.catalog["augments"] if item["parentSkill"]]
        common = [item for item in self.catalog["augments"] if not item["parentSkill"]]
        self.assertEqual(len(dedicated), 22)
        self.assertEqual(len(common), 3)
        for item in dedicated:
            parent = skills[item["parentSkill"]]
            for key in ("iconKey", "assetPath", "robloxAssetId", "iconStatus"):
                self.assertEqual(item[key], parent[key])
            self.assertEqual(item["iconMode"], "parent_with_badge")
            self.assertEqual(item["badge"]["variantName"], item["name"])
            self.assertTrue(item["badge"]["rarity"])
        for item in common:
            self.assertEqual(item["iconKey"], item["id"])
            self.assertEqual(item["iconMode"], "dedicated_common")
        unique = {s["iconKey"] for s in self.catalog["skills"] if s["assetPath"]} | {a["iconKey"] for a in common}
        self.assertEqual(len(unique), 19)
        for key in ("basic", "golem", "dash"):
            self.assertEqual(skills[key]["iconKey"], key)
            self.assertEqual(skills[key]["assetPath"], f"assets/ui/skill-icons/{key}.png")
            self.assertIn(skills[key]["iconStatus"], ("local_ready_unpublished", "uploaded"))
        self.assertEqual(self.catalog["counts"]["plannedUniqueImages"], 19)
        self.assertEqual(self.catalog["counts"]["builtinImagesPending"], 0)

    def test_manifest_rejects_fabricated_urls_paths_and_duplicate_ids(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            path = root / MANIFEST
            path.parent.mkdir(parents=True)
            good = {"id": "ice", "path": "assets/ui/skill-icons/ice.png", "robloxAssetId": None}
            for bad in ("rbxassetid://123", "https://example.com/image.png", 0, -1, True, 1.5):
                path.write_text(json.dumps({"icons": [{**good, "robloxAssetId": bad}]}))
                with self.assertRaises(ValueError):
                    upload_manifest(root)
            for records in ([good, good], [{**good, "path": "../outside.png"}], [{**good, "id": "unknown"}]):
                path.write_text(json.dumps({"icons": records}))
                with self.assertRaises(ValueError):
                    upload_manifest(root)
            path.write_text(json.dumps({"icons": [good]}))
            self.assertIsNone(upload_manifest(root)["ice"]["robloxAssetId"])
            path.write_text(json.dumps({"icons": [{**good, "robloxAssetId": "123456789"}]}))
            uploads = upload_manifest(root)
            self.assertEqual(uploads["ice"]["robloxAssetId"], "123456789")
            with self.assertRaisesRegex(ValueError, "missing.*local PNG"):
                icon_record("ice", uploads, root)

    def test_all_nineteen_local_images_match_manifest_provenance(self):
        manifest = json.loads((ROOT / MANIFEST).read_text(encoding="utf-8"))
        expected = {s["iconKey"] for s in self.catalog["skills"] if s["assetPath"]}
        expected |= {a["iconKey"] for a in self.catalog["augments"] if not a["parentSkill"]}
        self.assertEqual({item["id"] for item in manifest["icons"]}, expected)
        self.assertEqual(len(manifest["icons"]), 19)
        for item in manifest["icons"]:
            content = (ROOT / item["path"]).read_bytes()
            self.assertEqual(content[:8], b"\x89PNG\r\n\x1a\n", item["id"])
            self.assertEqual(struct.unpack(">II", content[16:24]), (item["width"], item["height"]), item["id"])
            self.assertEqual(len(content), item["bytes"], item["id"])
            self.assertEqual(hashlib.sha256(content).hexdigest(), item["sha256"], item["id"])

    def test_generated_json_markdown_and_client_helper_are_current(self):
        generated = outputs()
        self.assertEqual(generated, outputs())
        for path, text in generated.items():
            self.assertEqual((ROOT / path).read_text(encoding="utf-8"), text,
                             f"{path} is stale; run python3 tools/build_skill_catalog.py")

    def test_client_mapping_preserves_fallback_without_upload_id(self):
        catalog = copy.deepcopy(self.catalog)
        # Deliberately synthetic ID only in this temporary fixture, never in outputs.
        for item in catalog["skills"] + catalog["augments"]:
            item["robloxAssetId"] = "123456789" if item["iconKey"] == "ice" else None
        code = "local icons=(function()\n" + icon_helper(catalog) + "end)()\n" + r'''
local image={Image='old',Visible=true};local fallback={Visible=false}
local ready,entry=icons.Apply(image,'aug_ice_twin',fallback)
assert(ready and image.Image=='rbxassetid://123456789'and image.Visible and not fallback.Visible)
assert(entry.iconKey=='ice'and entry.parentSkill=='ice'and entry.badge=='희귀 · 쌍빙창')
ready,entry=icons.Apply(image,'meteor',fallback)
assert(not ready and image.Image==''and not image.Visible and fallback.Visible)
assert(entry.iconKey=='meteor')
ready,entry=icons.Apply(image,'unknown',fallback)
assert(not ready and entry==nil and image.Image==''and fallback.Visible)
assert(icons.Get('aug_ice_twin')==icons.Get('ice_twin'))
assert(icons.Get(123)==nil)
assert(#icons.List('all')==41 and #icons.List('auto')==9 and #icons.List('active')==4)
assert(#icons.List('augments')==25 and #icons.List('builtin')==3 and #icons.List('invalid')==0)
local results=icons.List('augments','빙결 얼음창');local found={}
for _,entry in ipairs(results)do found[entry.id]=true end
assert(found.ice_twin and found.ice_shatter and found.lightning_frozen,'Search includes parent and synergy conditions')
assert(icons.Get('ice_shatter').condition:find('2단계 이상',1,true))
assert(icons.Get('lightning_frozen').condition:find('서리 폭발',1,true))
assert(icons.Get('iceRush_wide').condition:find('Q에 빙하 쇄도 선택',1,true))
assert(#icons.List('all','[')==0,'Search uses literal text, never a Lua pattern')
local copy=icons.List('auto');table.remove(copy);assert(#icons.List('auto')==9)
assert(not pcall(function()icons.Get('ice').name='changed'end),'UI metadata is immutable')
for _,id in ipairs({'basic','golem','dash'})do
 local item=icons.Get(id);assert(item.assetPath=='assets/ui/skill-icons/'..id..'.png')
 local shown=icons.Apply(image,id,fallback);assert(not shown and image.Image==''and fallback.Visible)
end
print('PASS: icon readiness, fallback, immutable codex filtering and authoritative conditions')
'''
        suffix = ".exe" if os.name == "nt" else ""
        binary = ROOT / ".tools" / f"luau-{VERSION}" / ("luau" + suffix)
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", suffix=".luau", delete=False) as temp:
            temp.write(code)
            path = Path(temp.name)
        try:
            result = subprocess.run([str(binary), str(path)], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("PASS:", result.stdout)
        finally:
            path.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
