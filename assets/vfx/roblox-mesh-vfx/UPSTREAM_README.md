# ⚔️ Roblox AI Skills — Combat VFX & R6 Procedural Animation

Production-grade AI skills for fast-paced Roblox action games (*Deepwoken*, *Jujutsu
Shenanigans*, *Type Soul* style), for **Claude Code** and **Google Antigravity**.

Each skill is two things at once:

1. **A playbook** (`SKILL.md` + `references/`) that teaches the agent the right architecture,
   the math, the engine limits and the verified pitfalls;
2. **A drop-in, tested Luau library** (`src/`, a Rojo project) the agent builds on, with a
   playable demo.

Everything is `--!strict`, type-checked against the Roblox API definitions, linted, formatted
and unit-tested in CI (48 tests, including forward-kinematics proofs on a simulated R6 rig).

---

## 📦 Skills

### 1. [`roblox-mesh-vfx`](./.claude/skills/roblox-mesh-vfx/)
Client-rendered combat VFX with server authority.

- **Effects**: `Slash` (mesh or beam crescent), `Shockwave` (ground-aligned rings), `CraterRocks`
  (rocks + debris that take the color/material of the ground), `ImpactBurst` (sparks, flash,
  victim highlight), `GroundSlam` (combo) — all work with **zero assets** and upgrade to your
  Blender meshes automatically.
- **Game feel**: `Hitstop` (freezes every track, restores original speeds, stacks),
  `CameraShaker` (trauma² Perlin shake, directional kick, FOV punch, no drift),
  `ScreenFlash` (bloom/contrast/blur punches, manga impact frames), reduced-motion aware.
- **Engine**: one shared `Animator` loop (time-scale groups, batched `BulkMoveTo`, error
  isolation), `Pool`, `Fade` (fades decals/beams/particles too), `BeamArc`, `Particles`,
  `TextureAnimator` (UV scroll, flipbooks, spritesheets), analytic `Spring`.
- **Network**: 31-byte binary records batched per frame over `UnreliableRemoteEvent`,
  interest radius, seeded determinism, client prediction with `exclude`.

### 2. [`roblox-r6-procedural-animation`](./.claude/skills/roblox-r6-procedural-animation/)
Layered procedural motion for every visible R6 character (players and NPCs).

- **Layers**: `BodyLean` (speed + acceleration lean, physical turn banking, slope lean),
  `TerrainAdaptation` (pelvis drop + leg tuck/bend foot planting on stairs/rocks/slopes),
  `LandingImpact`, `HeadLook` (camera tracking, torso share, gaze stabilization, arm aim),
  `Breathing`.
- **Correct by construction**: offsets are written in Part0 space and layered on
  `Transform` in `PreSimulation` (works with Motor6D and AnimationConstraint, stacks with
  animations, never accumulates).
- **Multiplayer**: every client animates everyone locally; only head-look angles are
  replicated (4 bytes up, batched 12 bytes/player down, validated and rate-limited).
- **Scalable**: distance/on-screen LOD, attribute-based gameplay control (`R6_HeadLook = 0`...).

---

## 🚀 Install

### Claude Code (this repo)
Skills in `.claude/skills/` load automatically in Claude Code sessions opened on this
repository (local or cloud). To use them in another project, copy the folders into that
project's `.claude/skills/` (or `~/.claude/skills/` for all projects).

### Antigravity
- Workspace skills: `.agents/skills/` (mirrored copy).
- Global skills: copy `skills/*` into your Antigravity/Gemini global skills folder.

`.claude/skills` is the source of truth; `tools/sync-skills.sh` regenerates both copies and
CI fails if they drift.

### Use the Luau code in a game
Each skill folder is a Rojo project:
```bash
cd .claude/skills/roblox-mesh-vfx && rojo serve default.project.json
```
or copy `src/shared/*` → ReplicatedStorage, `src/server` → ServerScriptService,
`src/client` → StarterPlayerScripts (see each `SKILL.md` Quick start). The R6 skill needs
Game Settings → Avatar → R6.

---

## 🧪 Quality gates

```bash
tools/install-tools.sh   # pinned lune, stylua, selene, luau-lsp, rojo (or: rokit install)
tools/check.sh           # format + lint + strict type check + tests + copy sync
```

| Gate | Tool |
|---|---|
| Formatting | StyLua (`stylua.toml`) |
| Lint | Selene (`selene.toml`, offline Roblox std `roblox_min.yml`) |
| Types | luau-lsp `analyze`, Roblox definitions + Rojo sourcemaps, `--!strict` |
| Tests | Lune (`tools/test/`), real module sources in a mocked Roblox sandbox |

---

## 📄 License
MIT. Free to use and modify for personal and commercial Roblox games.
