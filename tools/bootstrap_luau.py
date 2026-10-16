"""Download checksum-pinned official Luau tools into the ignored .tools directory."""
import hashlib
import io
import platform
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERSION = "0.742"
PACKAGES = {
    "Darwin": ("macos", "bdd415766fbe03bc090b65fa6141531a4a54608db95a5350a5a0b49862bdac83"),
    "Linux": ("ubuntu", "152058b98c60ff1f5b5ec9bca0b8eb37793cae161dd3a05608cc3d8738ba1a4d"),
    "Windows": ("windows", "1114966cd8198f407069f07e8b4e6bacf2ded933e4a57d6ddc75617969278c75"),
}


def main():
    system = platform.system()
    if system not in PACKAGES:
        raise SystemExit(f"Unsupported platform: {system}")
    name, expected = PACKAGES[system]
    url = f"https://github.com/luau-lang/luau/releases/download/{VERSION}/luau-{name}.zip"
    with urllib.request.urlopen(url, timeout=60) as response:
        archive = response.read()
    if hashlib.sha256(archive).hexdigest() != expected:
        raise SystemExit("Luau archive checksum mismatch; nothing installed")
    target = ROOT / ".tools" / f"luau-{VERSION}"
    target.mkdir(parents=True, exist_ok=True)
    suffix = ".exe" if system == "Windows" else ""
    with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
        for tool in ("luau", "luau-compile", "luau-analyze"):
            dest = target / (tool + suffix)
            dest.write_bytes(bundle.read(tool + suffix))
            dest.chmod(0o755)
    print(f"Installed official Luau {VERSION} tools at {target}")


if __name__ == "__main__":
    main()
