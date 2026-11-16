#!/bin/sh
# Invoked from the webjcao website checkout by its systemd user service.
set -eu
umask 022

if [ "$(git symbolic-ref --quiet --short HEAD)" != main ]; then
    echo "The personal website checkout must be on main." >&2
    exit 1
fi
git fetch --quiet --no-tags origin refs/heads/main:refs/remotes/origin/main
target=$(git rev-parse 'refs/remotes/origin/main^{commit}')
current=$(git rev-parse HEAD)
if [ "$current" = "$target" ]; then
    exit 0
fi

if ! git -c core.fileMode=false diff --quiet || ! git -c core.fileMode=false diff --cached --quiet; then
    echo "Resolve local changes in the website checkout before deploying." >&2
    exit 1
fi
if ! git merge-base --is-ancestor "$current" "$target"; then
    echo "The personal website checkout cannot fast-forward to origin/main." >&2
    exit 1
fi

# Use the approved permission-preserving helper even on the first update.
helper=$(mktemp)
trap 'rm -f "$helper"' EXIT
git show "$target:gitpull.sh" > "$helper"
bash "$helper"
printf 'Deployed personal website %s\n' "$(git rev-parse HEAD)"
