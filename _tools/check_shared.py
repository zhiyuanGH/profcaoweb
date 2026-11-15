"""Check this personal-site snapshot using the pinned local IMCL catalog."""

import argparse
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--imcl-root", type=Path, required=True)
    source = parser.parse_args().imcl_root.resolve()
    expected = (ROOT / "shared-catalog.rev").read_text(encoding="ascii").strip()
    if not re.fullmatch("[0-9a-f]{40}", expected):
        parser.exit(1, "Invalid commit ID in shared-catalog.rev\n")
    try:
        revision = subprocess.check_output(["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
        if expected != revision:
            parser.exit(1, f"The personal site uses IMCL revision {expected}. Select that checkout.\n")
        dirty = subprocess.check_output(
            ["git", "-C", str(source), "status", "--porcelain", "--", "_tools/render_shared.py", "data/shared"],
            text=True,
        )
        if dirty:
            parser.exit(1, "The pinned catalog or renderer has local changes. Use a clean source checkout.\n")
        return subprocess.run([
            sys.executable, str(source / "_tools/render_shared.py"),
            "--site", "prof", "--prof-root", str(ROOT), "--check",
        ]).returncode
    except (OSError, subprocess.CalledProcessError) as exc:
        parser.exit(1, f"Could not verify the local IMCL checkout: {exc}\n")


if __name__ == "__main__":
    raise SystemExit(main())
