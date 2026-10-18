"""Guard provenance and Studio's per-script Source length limit for generated assets."""
import hashlib,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class SkeletonAssets(unittest.TestCase):
 def test_pinned_source_hashes(self):
  folder=ROOT/'assets/enemies/kaykit-skeletons'
  manifest=json.loads((folder/'manifest.json').read_text())
  self.assertEqual(manifest['license'],'CC0 1.0')
  self.assertEqual(len(manifest['revision']),40)
  self.assertEqual(set(manifest['characters']),{'Warrior','Mage','Rogue','Minion'})
  for name in manifest['gear']:
   self.assertIn('gear/Skeleton_'+name+'.gltf',manifest['files'])
   self.assertIn('gear/Skeleton_'+name+'.bin',manifest['files'])
  for name,expected in manifest['files'].items():
   self.assertEqual(hashlib.sha256((folder/name).read_bytes()).hexdigest(),expected,name)
 def test_studio_source_limit(self):
  for path in (ROOT/'src/client/world').rglob('*.luau'):
   self.assertLess(len(path.read_text()),200000,path.name)
