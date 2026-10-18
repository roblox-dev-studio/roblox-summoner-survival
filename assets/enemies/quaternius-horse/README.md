# Quaternius Horse (CC0)

Publisher: https://quaternius.com/packs/ultimateanimatedanimals.html
Exact model/distribution: https://poly.pizza/m/qvTrSG9pZF
License: CC0 1.0. Original GLB is retained; SHA-256 is in manifest.json.

This is the actual mesh/skin/Idle/Walk/Gallop source used by the commander, not only a visual reference. No external scripts or textures are loaded. Eight original material colors are converted from linear to sRGB vertex colors.

Reproduce with `python3 tools/convert_horse.py` in a NumPy environment, then `python3 tools/build_installer.py`. The checked-in generated modules do not require NumPy at build/runtime. Converter bakes ancestor scales into global geometry/bone poses, converts +Z to Roblox -Z, grounds the hooves, and emits small local data modules. Runtime HorseMesh uses one fixed EditableMesh and per-instance native Bones, preserving the 67-node hierarchy and skin weights. The saddle/rider follows the animated back.

Original pack contains other animations, but only Idle/Walk/Gallop are generated for this version. The hooded rider, greatsword and saddle are authored by this project and are not Quaternius models.
