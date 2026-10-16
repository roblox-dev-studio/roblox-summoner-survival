"""Package source modules into a deterministic, edit-mode Studio installer."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENTRYPOINTS = (
    ("server", "Script", "SummonerServer", "game.ServerScriptService"),
    ("client", "LocalScript", "SummonerClient", "game.StarterPlayer.StarterPlayerScripts"),
)


def quote(text):
    return json.dumps(text, ensure_ascii=False)


def source_literal(source):
    # Long strings strip one initial newline. Prefix it to preserve the source exactly.
    equals = "===="
    while "]" + equals + "]" in source:
        equals += "="
    return "[" + equals + "[\n" + source + "]" + equals + "]"


def modules_for(root, side):
    base = root / "src" / side
    paths = sorted(base.rglob("*.luau"))
    if not paths:
        raise ValueError(f"No {side} modules found in {base}")
    occupied = {}
    for path in paths:
        parts = path.relative_to(base).with_suffix("").parts
        for part in parts:
            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", part):
                raise ValueError(f"Invalid Roblox module name: {path}")
        for depth in range(1, len(parts) + 1):
            name = "/".join(parts[:depth])
            kind = "module" if depth == len(parts) else "folder"
            key = name.casefold()
            if key in occupied and occupied[key] != (name, kind):
                raise ValueError(f"Module/folder name collision: {name}")
            occupied[key] = (name, kind)
    return paths


def build(root=ROOT):
    header = (root / "tools/installer_header.luau").read_text(encoding="utf-8")
    if header.count("-- @ARENA@") != 1:
        raise ValueError("Missing or duplicate arena placeholder")
    output = header.replace("-- @ARENA@", (root / "arena.luau").read_text(encoding="utf-8").rstrip())
    output += '\n-- Generated below. Edit src/ and entrypoints, then rebuild.\n'
    output += '''local function addModule(parent, path, source)
    for i=1,#path-1 do
        local folder=parent:FindFirstChild(path[i])
        if not folder then folder=Instance.new("Folder");folder.Name=path[i];folder.Parent=parent end
        parent=folder
    end
    local module=Instance.new("ModuleScript")
    module.Name=path[#path];module.Source=source;module.Parent=parent
end
'''
    for side, kind, name, parent in ENTRYPOINTS:
        source = (root / f"{side}.luau").read_text(encoding="utf-8")
        output += f'\ndo\nlocal entry=Instance.new({quote(kind)})\nentry.Name={quote(name)}\n'
        output += f'entry.Source={source_literal(source)}\n'
        output += 'local modules=Instance.new("Folder");modules.Name="Modules";modules.Parent=entry\n'
        for path in modules_for(root, side):
            parts = path.relative_to(root / "src" / side).with_suffix("").parts
            address = "{" + ",".join(quote(part) for part in parts) + "}"
            output += f'-- Source: {path.relative_to(root).as_posix()}\n'
            output += f'addModule(modules,{address},{source_literal(path.read_text(encoding="utf-8"))})\n'
        # All children exist before the entrypoint can execute.
        output += f'entry.Parent={parent}\nend\n'
    output += 'print("Summoner Survival installed. Save your place and press Play.")\n'
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Check without changing files")
    args = parser.parse_args()
    output = build()
    target = ROOT / "install.luau"
    if args.check:
        if not target.exists() or target.read_text(encoding="utf-8") != output:
            raise SystemExit("Installer is outdated. Run python3 tools/build_installer.py")
        print("Installer matches source files and modules.")
    else:
        target.write_text(output, encoding="utf-8")
        print("Built install.luau")


if __name__ == "__main__":
    main()
