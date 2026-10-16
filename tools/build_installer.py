"""Build the Studio installer from the three editable Luau source files."""
import argparse
from pathlib import Path

root = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--check", action="store_true", help="Check without changing files")
args = parser.parse_args()
header = (root / "tools/installer_header.luau").read_text()
assert header.count("-- @ARENA@") == 1, "Missing or duplicate arena placeholder"
output = header.replace("-- @ARENA@", (root / "arena.luau").read_text().rstrip())
for filename, kind, name, parent in (
    ("server.luau", "Script", "SummonerServer", "game.ServerScriptService"),
    ("client.luau", "LocalScript", "SummonerClient", "game.StarterPlayer.StarterPlayerScripts"),
):
    source = (root / filename).read_text()
    assert "]====]" not in source, f"Unsafe long-string delimiter in {filename}"
    output += f'local s=Instance.new("{kind}"); s.Name="{name}"; s.Source=[====[\n'
    output += source + f'\n]====]; s.Parent={parent}\n'
output += 'print("Summoner Survival installed. Save your place and press Play.")\n'
target = root / "install.luau"
if args.check:
    if not target.exists() or target.read_text() != output:
        raise SystemExit("Installer is outdated. Run python3 tools/build_installer.py")
    print("Installer matches source files.")
else:
    target.write_text(output)
    print("Built install.luau")
