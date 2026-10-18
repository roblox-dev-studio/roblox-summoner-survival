"""Bake six real Quaternius GLB actions onto the measured Roblox R15 bind.

Run in isolated Blender: blender --background --python tools/convert_player_motion.py
No paid account, runtime animation upload, synthetic keys, or other project is needed.
The original Roll action is adapted as a visual air tumble; physics stay in Roblox.
"""
from pathlib import Path
import hashlib
import json
import math

import bpy
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets/animations/quaternius-locomotion"
SOURCE = ASSETS / "AnimationLibrary_Godot_Standard.glb"
OUTPUT = ROOT / "src/client/world/clips"
SELECTED = {
    "Walk_Loop": True, "Jog_Fwd_Loop": True, "Jump_Start": False,
    "Jump_Loop": True, "Jump_Land": False, "Roll": False,
}


def matrix(c):
    return Matrix(((c[3], c[4], c[5], c[0]), (c[6], c[7], c[8], c[1]),
                   (c[9], c[10], c[11], c[2]), (0, 0, 0, 1)))


def rotation(m):
    return m.to_quaternion().normalized().to_matrix()


def bake():
    rig = json.loads((ASSETS / "r15-bind-data.json").read_text())
    axis = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
    def convert(m):
        return axis @ m @ axis.inverted()
    ordered, pending, neutral = [], rig["joints"][:], {"HumanoidRootPart": Matrix.Identity(4)}
    while pending:
        before = len(pending)
        for j in pending[:]:
            if j["a0"] in neutral:
                neutral[j["a1"]] = neutral[j["a0"]] @ matrix(j["cf0"]) @ matrix(j["cf1"]).inverted()
                ordered.append(j)
                pending.remove(j)
        assert len(pending) < before, "Disconnected R15 joints"

    scene = bpy.data.scenes.new("Summoner - Quaternius locomotion conversion")
    if bpy.context.window:
        bpy.context.window.scene = scene
    scene.render.fps = 30
    scene.render.fps_base = 1
    with bpy.context.temp_override(scene=scene, view_layer=scene.view_layers[0]):
        before = set(bpy.data.objects)
        old_actions = set(bpy.data.actions)
        bpy.ops.import_scene.gltf(filepath=str(SOURCE))
        sources = [o for o in bpy.data.objects if o not in before and o.type == "ARMATURE"]
        assert len(sources) == 1
        src = sources[0]
        actions = {a.name: a for a in bpy.data.actions if a not in old_actions}
        assert all(name in actions for name in SELECTED), "Missing provider action"
        mapping = {"Root": "DEF-hips", "Waist": "DEF-spine.003", "Neck": "DEF-head"}
        endpoints = {}
        for side, suffix in (("Left", "L"), ("Right", "R")):
            for joint, source, child in (
                ("Shoulder", "upper_arm", "forearm"), ("Elbow", "forearm", "hand"),
                ("Wrist", "hand", "f_middle.01"), ("Hip", "thigh", "shin"),
                ("Knee", "shin", "foot"), ("Ankle", "foot", "toe"),
            ):
                mapping[side + joint] = f"DEF-{source}.{suffix}"
                endpoints[side + joint] = f"DEF-{child}.{suffix}"
        assert all(name in src.data.bones for name in mapping.values())
        def rest_pos(name):
            return (src.matrix_world @ src.data.bones[name].matrix_local).translation
        right = (rest_pos("DEF-thigh.R") - rest_pos("DEF-thigh.L")).normalized()
        up = (rest_pos("DEF-head") - rest_pos("DEF-hips")).normalized()
        up = (up - right * up.dot(right)).normalized()
        canonical = Matrix((right, -right.cross(up).normalized(), up)).transposed().inverted()
        target_rest = {name: rotation(convert(m)) for name, m in neutral.items()}
        calibration = {}
        for j in ordered:
            name = j["name"]
            bone = src.data.bones[mapping[name]]
            sr = canonical @ rotation(src.matrix_world @ bone.matrix_local)
            reference = target_rest[j["a1"]]
            if name in endpoints:
                direction = canonical @ (rest_pos(endpoints[name]) - rest_pos(mapping[name]))
                direction.normalize()
                children = [x for x in ordered if x["a0"] == j["a1"]]
                if children:
                    local = matrix(children[0]["cf0"]).translation - matrix(j["cf1"]).translation
                elif name.endswith("Ankle"):
                    size = next(p["size"] for p in rig["parts"] if p["name"] == j["a1"])
                    pivot = matrix(j["cf1"]).translation
                    local = Vector((pivot.x, -size[1] * .5, -size[2] * .5)) - pivot
                else:
                    local = Vector((0, -1, 0))
                target = (convert(neutral[j["a1"]]).to_3x3() @ (axis.to_3x3() @ local)).normalized()
                reference = target.rotation_difference(direction).to_matrix() @ reference
            calibration[name] = sr.inverted() @ reference

        records = []
        for name, loop in SELECTED.items():
            action = actions[name]
            src.animation_data_create()
            src.animation_data.action = action
            if action.slots:
                src.animation_data.action_slot = action.slots[0]
            for track in src.animation_data.nla_tracks:
                track.mute = True
            start, end = action.frame_range
            duration = (end - start) / 30
            assert 0 < duration < 10
            rows = []
            for n in range(math.ceil(duration * 60) + 1):
                frame = start + min(n / 60, duration) * 30
                scene.frame_set(math.floor(frame), subframe=frame % 1)
                bpy.context.view_layer.update()
                evaluated = src.evaluated_get(bpy.context.evaluated_depsgraph_get())
                world = {"HumanoidRootPart": Matrix.Identity(4)}
                row = [0, 0, 0]  # In-place: Humanoid owns all displacement, including height.
                for j in ordered:
                    desired = canonical @ rotation(evaluated.matrix_world @ evaluated.pose.bones[mapping[j["name"]]].matrix) @ calibration[j["name"]]
                    desired = axis.to_3x3().inverted() @ desired @ axis.to_3x3()
                    parent = world[j["a0"]] @ matrix(j["cf0"])
                    transform = rotation(parent).inverted() @ desired @ rotation(matrix(j["cf1"]))
                    world[j["a1"]] = parent @ transform.to_4x4() @ matrix(j["cf1"]).inverted()
                    values = (math.atan2(-transform[1][2], transform[2][2]),
                              math.asin(max(-1, min(1, transform[0][2]))),
                              math.atan2(-transform[0][1], transform[0][0]))
                    row.extend(round(v * 100000) for v in values)
                rows.append(row)
            names = [j["name"] for j in ordered]
            lines = ["--!strict", "-- Quaternius CC0 original action; R15 retarget. See assets/animations/quaternius-locomotion.",
                     "local joints={" + ",".join(json.dumps(n) for n in names) + "}", "local rows={"]
            lines.extend("{" + ",".join(map(str, row)) + "}," for row in rows)
            lines.extend(["}", f'local clip={{Duration={duration},Loop={str(loop).lower()},Source="Quaternius original GLB",Role="{name}",Frames={{}}}}',
                          "for i,row in rows do", " local pose:{[string]:CFrame}={}",
                          " for j,joint in joints do local k=4+(j-1)*3;pose[joint]=CFrame.Angles(row[k]/100000,row[k+1]/100000,row[k+2]/100000) end",
                          " clip.Frames[i]={Time=math.min((i-1)/60,clip.Duration),Pose=pose}", "end", "return clip"])
            path = OUTPUT / (name + ".luau")
            path.write_text("\n".join(lines) + "\n")
            records.append({"name": name, "file": str(path.relative_to(ROOT)), "duration": duration,
                            "frames": len(rows), "loop": loop, "sourceAction": name,
                            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
        manifest = {"provider": "Quaternius", "pack": "Universal Animation Library Standard (OpenGameArt release)",
                    "source": "https://opengameart.org/content/universal-animation-library", "license": "CC0-1.0",
                    "originalGLB": str(SOURCE.relative_to(ROOT)), "originalGLBSHA256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
                    "target": "Measured Roblox R15 Motor6D C0/C1", "sampleRate": 60, "rootTranslation": "removed on all axes",
                    "doubleJumpAdaptation": "Original Roll rotations compressed to 0.55 seconds for an air tumble; not a provider-authored double jump.",
                    "scriptsImported": False, "clips": records}
        (ASSETS / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
        return records


if __name__ == "__main__":
    print(json.dumps(bake(), indent=2))
