# Personal website deployment

The `webjcao` account on Apollo publishes the personal website from
`/webhome/webjcao/public_html`. Its systemd user timer checks this repository's
`main` every five minutes. Each run fetches `origin/main` using the checkout's
existing read-only GitHub access. If the commit matches the installed version,
the run ends before scanning the website files.

## Install after release approval

Log in as `webjcao` on Apollo. The checkout must use the personal repository as
`origin` and have its local `main` branch checked out. Its Git credentials must
work without a prompt. For SSH, use this account's trusted GitHub host key and
its own read-only deploy key. Git, Bash, Python 3 and a systemd user manager
are required.

To run after logout and reboot, check `loginctl show-user webjcao -p Linger`.
If it reports `Linger=no`, run `loginctl enable-linger webjcao`. A host
administrator must enable lingering if local policy denies this request.

Once the release is merged, the following Bash commands install the units
from the approved `origin/main` even when the website checkout still predates
the timer. Installation starts the timer and runs one update immediately.

```bash
cd /webhome/webjcao/public_html
(
  set -euo pipefail
  git fetch --no-tags origin refs/heads/main:refs/remotes/origin/main
  install_from=$(mktemp -d)
  trap 'rm -rf "$install_from"' EXIT
  git archive origin/main -- ops | tar -x -C "$install_from"
  sh "$install_from/ops/install-timer.sh"
)
```

The installer uses a regular `timers.target.d/profcaoweb-deploy.conf` drop-in
under `~/.config/systemd/user/` to start the timer on Apollo's SMB home
directory. When a later release changes files under `ops/`, run these same
installation commands to refresh the installed copies.

## Check, run and stop

```bash
systemctl --user list-timers profcaoweb-deploy.timer
journalctl --user -u profcaoweb-deploy.service -n 30
```

Use `systemctl --user start profcaoweb-deploy.service` for an immediate check.
The timer and manual check use the same service, which systemd runs once at a
time. To turn off automatic checks, stop the timer, remove its drop-in and
reload the user manager:

```bash
systemctl --user stop profcaoweb-deploy.timer
rm -f ~/.config/systemd/user/timers.target.d/profcaoweb-deploy.conf
systemctl --user daemon-reload
```

When an update is available, the service checks for local edits to tracked
files (including staged changes) and a
fast-forward path before running the repository's `gitpull.sh`. That helper
pulls `origin main` and restores the POSIX modes of existing regular files
and directories, including after a failed pull. It skips symlinks and Git
metadata. New files take their Git executable bit and the deployment umask.
The helper updates the checkout in place. Ownership, ACLs and extended
attributes are outside its permission snapshot. The helper sets
`core.fileMode=false` locally to ignore server-specific executable bits.

For a content rollback, revert the release in the owning repository through
its normal PR process. Once that revert reaches personal-site `main`, the
next timer run can fast-forward to it.
