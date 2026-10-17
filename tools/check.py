"""Local and CI gate: installer parity, packager tests, Luau syntax and global names."""
import re
import subprocess
import sys
from build_installer import ROOT
from bootstrap_luau import VERSION

# CLI Luau has no Roblox globals. Catch leaked upvalues without claiming full engine type analysis.
ROBLOX_GLOBALS = {
    "game", "workspace", "script", "Instance", "Enum", "Vector2", "Vector3", "CFrame",
    "Color3", "UDim", "UDim2", "Random", "RaycastParams", "TweenInfo", "NumberRange",
    "NumberSequence", "NumberSequenceKeypoint", "ColorSequence", "ColorSequenceKeypoint",
    "task", "warn", "Content",
}


def main():
    suffix = ".exe" if sys.platform == "win32" else ""
    tool_dir = ROOT / ".tools" / f"luau-{VERSION}"
    compiler = tool_dir / ("luau-compile" + suffix)
    analyzer = tool_dir / ("luau-analyze" + suffix)
    if not compiler.exists() or not analyzer.exists():
        raise SystemExit("Run python3 tools/bootstrap_luau.py first")
    subprocess.run([sys.executable, "tools/build_installer.py", "--check"], cwd=ROOT, check=True)
    subprocess.run([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_*.py"], cwd=ROOT, check=True)
    sources = [ROOT / name for name in ("server.luau", "client.luau", "arena.luau", "install.luau")]
    sources += sorted((ROOT / "src").rglob("*.luau"))
    for path in sources:
        result = subprocess.run([str(compiler), str(path)], stdout=subprocess.DEVNULL,
                                stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace")
        if result.returncode:
            raise SystemExit(result.stderr or f"Compilation failed: {path}")
    # Only UnknownGlobal lint is enforced here. Roblox engine type diagnostics are unavailable.
    result = subprocess.run([str(analyzer), *map(str, sources)], capture_output=True, text=True)
    output = result.stdout + result.stderr
    failures = []
    for line in output.splitlines():
        match = re.search(r"Unknown global '([^']+)'", line)
        if match and match[1] not in ROBLOX_GLOBALS:
            failures.append(line)
    if result.returncode not in (0, 1) or (result.returncode and not output.strip()):
        raise SystemExit(f"Analyzer failed ({result.returncode}): {output}")
    if failures:
        raise SystemExit("\n".join(failures))
    subprocess.run([str(tool_dir / ("luau" + suffix)), "tests/progression.spec.luau"], cwd=ROOT, check=True)
    print(f"PASS: {len(sources)} Luau files compile; no unexpected globals. Studio playtest still required.")


if __name__ == "__main__":
    main()
