"""Keep imported horse provenance pinned and its source data reproducible."""
from pathlib import Path
import hashlib,json,unittest
ROOT=Path(__file__).resolve().parents[1]
class HorseAssets(unittest.TestCase):
 def test_source_and_animation_provenance(self):
  root=ROOT/'assets/enemies/quaternius-horse';manifest=json.loads((root/'manifest.json').read_text())
  self.assertEqual(manifest['author'],'Quaternius');self.assertEqual(manifest['license'],'CC0 1.0')
  self.assertEqual(hashlib.sha256((root/'Horse.glb').read_bytes()).hexdigest(),manifest['sha256'])
  self.assertFalse(manifest['scriptsImported']);self.assertLessEqual(manifest['triangles'],5000)
  self.assertEqual(manifest['clips'],{'Idle':'Idle','Walk':'Walk','Gallop':'Gallop'})
  for name in manifest['clips']:self.assertTrue((ROOT/manifest['generated']/(name+'.luau')).is_file())
