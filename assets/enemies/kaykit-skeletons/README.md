# KayKit Skeleton enemies and equipment · CC0 1.0

Original creator: Kay Lousberg / KayKit. Pinned public Character Pack Skeletons **1.0**,
not itch.io's newer Free 1.1 and not the paid EXTRA pack.

Source: https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0/tree/15b62b9bad122f72926c10fb14d622c73819fa54

Original files under that commit:

- `LICENSE.txt`
- `addons/kaykit_character_pack_skeletons/Characters/gltf/Skeleton_{Warrior,Mage,Rogue,Minion}.glb`
- `addons/kaykit_character_pack_skeletons/Characters/gltf/skeleton_texture.png`
- `addons/kaykit_character_pack_skeletons/Assets/gltf/Skeleton_{Axe,Blade,Shield_Large_A,Shield_Small_A,Staff}.{gltf,bin}`
- `addons/kaykit_character_pack_skeletons/Assets/gltf/skeleton_texture.png` (identical palette, SHA-256 checked)

Download the same paths from `raw.githubusercontent.com/KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0/15b62b9bad122f72926c10fb14d622c73819fa54/`.
The committed manifest records original SHA-256 hashes. No bundled source code was imported or executed.

With Python 3, numpy and Pillow installed, run from the repository root:

```sh
python3 tools/convert_skeleton.py --character Warrior
python3 tools/convert_skeleton.py --character Mage
python3 tools/convert_skeleton.py --character Rogue
python3 tools/convert_skeleton.py --character Minion
python3 tools/convert_enemy_gear.py
python3 tools/build_installer.py
python3 tools/check.py
```

Output: `src/client/world/skeleton/`, `skeletonMage/`, `skeletonRogue/`, `skeletonMinion/`, and `gearAssets/`. UV palette sampled into vertex colors, front rotated
from +Z to -Z, scale 3.5 studs/unit. Original vertex weights and 42-node rig preserved.
Original clips are sampled at 20 fps (specific clip names are in manifest.characters).
Warrior also has 1H chop for armed elites/executioners; Mage has casting and windup;
Rogue has running/dual-wield attacks; Minion has running/cheer for the bomber. Runtime interpolates native Bone transforms; it does not
skin every vertex on the CPU. One immutable fixed-size EditableMesh per asset is shared across instances.
Normal/color/UV attributes are deduplicated; unused generated attributes are removed before
creating the fixed-size copy to stay within the client mesh budget.
Generated data is split into modules below Studio's 200,000-character Source limit.
No Roblox asset IDs, image uploads or paid files are needed. Mesh/Image APIs must be enabled.

Server models retain their existing visible fallback and hit anchor. Successful local mesh
creation hides only the fallback; failure keeps it visible. Gameplay damage/health/XP are unchanged.

Roles keep their existing gameplay IDs: stalker=Warrior, skitter=Rogue, brute=larger Warrior,
caster=Mage, ember=Minion with an original procedural bomb. Charger is the original
procedural AshHound, not a KayKit model. Bone hand attachments carry original KayKit
weapons/shields/staff; scale and elite rebuilds do not create new mesh assets.

Warrior currently uses `Walking_A`. `Walking_D_Skeletons` was the first trial but
its persistent 12–17 degree head tilt did not fit the requested upright appearance.
The temporary spine-centering correction was removed; the original balanced clip is used.
