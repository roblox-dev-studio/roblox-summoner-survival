# Agent working agreement

This repository is a 3D survival game inspired by Vampire Survivors. Read `README.md`,
`docs/ARCHITECTURE.md`, and `CONTRIBUTING.md` before changing code. Keep this file short;
task details belong in an issue or PR, not a growing global instruction log.

## Scope and ownership

- Work in the feature area named by the current task: combat/summons, enemies/world,
  or progression/play flow. Each area includes its server logic and client presentation.
- Ownership is assigned per issue, not permanently by frontend/backend job title.
  Check the issue/PR for who is editing the same files before overlapping work.
- `server.luau`, `client.luau`, shared helpers, network contracts, and installer/CI are
  integration surfaces. Describe cross-area changes in the PR and request a teammate review.
- Do not launch extra agents or recurring monitors unless requested. Do not wake archived
  FPS/AFTERLIGHT chats. One active task and one branch per agent working directory.

## Implementation

- Preserve existing behavior for refactors. Separate feature changes from structural changes.
- Author modules in `src/`; `install.luau` is generated. Never hand-edit its embedded sources.
- Server owns damage, cooldowns, XP, upgrades, drops and round results. Client submits intent.
  Validate all new remote payloads, state, permissions and rate limits on the server.
- Pass dependencies explicitly. Do not add `_G`, `shared`, remote `loadstring`, numeric asset
  `require`, or a global service locator to connect modules.
- Keep server modules under the server entrypoint; never replicate authoritative server code.
- External assets need source, creator and usage conditions in `ASSET_CREDITS.md`.
  Inspect imported scripts; do not execute bundled untrusted code automatically.
- Gameplay source of truth is Git. Export Studio-only assets to a reproducible text/model
  source with an import path before claiming they are handed off. Never commit secrets.

## Checks and handoff

1. Run `python3 tools/bootstrap_luau.py` once on a new machine.
2. Run `python3 tools/build_installer.py` after source changes.
3. Run `python3 tools/check.py`; report any failure. Do not weaken checks to pass a change.
4. Test affected behavior in a new disposable Studio Baseplate. Identify the exact Studio
   instance first; do not overwrite another project or another person's test session.
5. Follow `docs/PLAYTEST_CHECKLIST.md`. Record the commit/source revision, environment,
   observed result and remaining gaps. Static checks, simulated tests, actual engine tests,
   visual/audio review and human enjoyment are different evidence levels.
6. Submit a focused PR with the template. Do not merge your own change or publish the game
   unless the user explicitly asks. Regenerate the installer after resolving source conflicts.

Update relevant docs in the same change: architecture/contracts for module changes,
ASSET_CREDITS and an asset manifest for reused materials, PLAYTEST_NOTES for observed
results and remaining gaps. Keep dated evidence concise; do not label untested work complete.

If Studio is unavailable, finish source checks and clearly mark engine verification pending.
Do not claim a local file, mock, or successful tool call proves the feature is in the game.
If a repair repeats without new evidence, state the concrete blocker and choose a smaller
test; do not spend indefinitely tuning constants or adding more documentation.
