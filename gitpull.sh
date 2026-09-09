#!/bin/bash

# Run from the server checkout. Python loads the entire script before Git can
# replace it, so updating gitpull.sh during deployment is safe.
set -euo pipefail
exec python3 - <<'PY'
import os
import stat
import subprocess
import sys
from pathlib import Path


root = Path(subprocess.check_output(
    ["git", "rev-parse", "--show-toplevel"], text=True
).rstrip("\n"))
os.chdir(root)
subprocess.run(["git", "config", "--local", "core.fileMode", "false"], check=True)

# Snapshot existing POSIX modes, including directories. Do not traverse
# symlinks or Git metadata, and fail before pulling if a directory is unreadable.
def walk_error(error):
    raise error


modes = {}
for directory, subdirs, files in os.walk(".", onerror=walk_error, followlinks=False):
    subdirs[:] = [name for name in subdirs
                 if name != ".git" and not Path(directory, name).is_symlink()]
    for path in [Path(directory)] + [Path(directory, name) for name in files
                                    if name != ".git"]:
        info = path.lstat()
        if stat.S_ISREG(info.st_mode) or stat.S_ISDIR(info.st_mode):
            modes[path] = (stat.S_IFMT(info.st_mode), stat.S_IMODE(info.st_mode))

result = 1
restore_errors = []
try:
    result = subprocess.run([
        "git", "-c", "pull.rebase=false", "pull", "--ff-only", "origin", "main"
    ]).returncode
finally:
    # Restore on both success and failure. Deleted/retyped paths have no
    # matching permissions to restore; new paths use Git's mode and the umask.
    for path, (kind, mode) in modes.items():
        try:
            if any(parent.is_symlink() for parent in (path, *path.parents)):
                continue
            try:
                info = path.lstat()
            except (FileNotFoundError, NotADirectoryError):
                continue
            if stat.S_IFMT(info.st_mode) == kind and stat.S_IMODE(info.st_mode) != mode:
                path.chmod(mode)
        except OSError as error:
            restore_errors.append((path, error))

for path, error in restore_errors:
    print("Could not restore permissions for {}: {}".format(path, error), file=sys.stderr)
if restore_errors and result == 0:
    sys.exit(1)
sys.exit(result if result >= 0 else 128 - result)
PY
